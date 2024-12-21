import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Color, rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart' as path;

// Unified Notification Action class
class NotificationAction {
  final String id;
  final String title;
  final NotificationActionType type;
  final Map<String, dynamic>? options;
  final String? iconPath;

  const NotificationAction({
    required this.id,
    required this.title,
    this.type = NotificationActionType.plain,
    this.options,
    this.iconPath,
  });

  // Convert to Android Notification Action
  Future<AndroidNotificationAction?> toAndroidNotificationAction() async {
    // Process icon if provided
    String? processedIconPath;
    if (iconPath != null) {
      processedIconPath = await _processActionIcon(iconPath!);
    }

    return AndroidNotificationAction(
      id,
      title,
      icon: processedIconPath != null ? FilePathAndroidBitmap(processedIconPath) : null,
      contextual: false,
      showsUserInterface: true,
    );
  }

  // Convert to Darwin (iOS/macOS) Notification Action
  DarwinNotificationAction toDarwinNotificationAction() {
    switch (type) {
      case NotificationActionType.text:
        return DarwinNotificationAction.text(
          id,
          title,
          buttonTitle: options?['buttonTitle'] ?? 'Send',
          placeholder: options?['placeholder'] ?? '',
        );
      case NotificationActionType.plain:
        final actionOptions = <DarwinNotificationActionOption>{};

        // Handle destructive option
        if (options?['destructive'] == true) {
          actionOptions.add(DarwinNotificationActionOption.destructive);
        }

        // Handle foreground option
        if (options?['foreground'] == true) {
          actionOptions.add(DarwinNotificationActionOption.foreground);
        }

        return DarwinNotificationAction.plain(
          id,
          title,
          options: actionOptions,
        );
    }
  }

  // Utility method to process action icon (moved from previous implementation)
  Future<String?> _processActionIcon(String iconPath) async {
    try {
      // Check if it's a network image
      if (iconPath.startsWith('http://') || iconPath.startsWith('https://')) {
        final response = await http.get(Uri.parse(iconPath));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_action_icon.png');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }

      // Check if it's an asset image
      if (path.extension(iconPath) != '') {
        final byteData = await rootBundle.load(iconPath);
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_action_icon.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      }

      // Assume it's a local file path
      return iconPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing action icon: $e');
      }
      return null;
    }
  }
}

// Enum remains the same
enum NotificationActionType {
  plain,
  text,
}

// Notification Category class to group actions
class NotificationCategory {
  final String identifier;
  final List<NotificationAction> actions;

  const NotificationCategory({
    required this.identifier,
    required this.actions,
  });

  // Convert to Android Notification Category (if needed)
  Future<List<AndroidNotificationAction>> toAndroidNotificationActions() async {
    final androidActions = <AndroidNotificationAction>[];
    for (var action in actions) {
      final androidAction = await action.toAndroidNotificationAction();
      if (androidAction != null) {
        androidActions.add(androidAction);
      }
    }
    return androidActions;
  }

  // Convert to Darwin Notification Category
  DarwinNotificationCategory toDarwinNotificationCategory() {
    return DarwinNotificationCategory(
      identifier,
      actions: actions.map((action) => action.toDarwinNotificationAction()).toList(),
    );
  }
}

// Updated NotificationConfig to include Android categories
class NotificationConfig {
  final String androidAppIcon;
  final String assetAppIcon;
  final String androidChannelId;
  final String androidChannelName;
  final String defaultActionName;
  final String androidChannelDescription;
  final String notificationSoundResource;
  final List<NotificationCategory>? darwinActionCategories;
  final List<NotificationCategory>? androidActionCategories;
  final List<AndroidNotificationAction>? androidActions;

  NotificationConfig({
    this.androidAppIcon = 'app_icon',
    this.assetAppIcon = 'icons/app_icon.png',
    this.androidChannelId = 'default_channel_id',
    this.androidChannelName = 'Default Channel',
    this.defaultActionName = 'Open Notification',
    this.androidChannelDescription = 'General notifications',
    this.notificationSoundResource = 'notification_sound',
    this.darwinActionCategories,
    this.androidActionCategories,
    this.androidActions,
  });

}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late NotificationConfig _config;

  // Callbacks for Firebase messages
  void Function(RemoteMessage)? _onForegroundMessage;
  void Function(RemoteMessage)? _onMessageOpenedApp;

  // Notification tap callback
  void Function(NotificationResponse)? _onNotificationTapCallback;

  // FCM Token
  String? _fcmToken;

  // Getter for FCM token
  String? get fcmToken => _fcmToken;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService({NotificationConfig? config}) {
    if (config != null) {
      _instance._updateConfig(config);
    }
    return _instance;
  }

  NotificationService._internal() {
    // Initialize with default config if not set
    _config = NotificationConfig();
    initialize();
  }

  // Update configuration
  void _updateConfig(NotificationConfig newConfig) {
    _config = newConfig;
  }

  // Getter for config
  NotificationConfig get config => _config;

  // Notification permission status
  bool _notificationPermissionGranted = false;

  // Getter for notification permission status
  bool get isNotificationPermissionGranted => _notificationPermissionGranted;

  // Initialize notification service
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
    void Function(RemoteMessage)? onForegroundMessage,
    void Function(RemoteMessage)? onMessageOpenedApp,
    List<NotificationCategory>? androidCategories,
    List<NotificationCategory>? darwinCategories,
  }) async {
    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Store callbacks
      _onNotificationTapCallback = onNotificationTap;
      _onForegroundMessage = onForegroundMessage;
      _onMessageOpenedApp = onMessageOpenedApp;

      // Configure FCM handlers
      await _configureFCM();

      // Request FCM token
      await _getFCMToken();
      // Ensure the app is initialized for notifications
      await _configureLocalTimeZone();

      // Request notification permissions
      await _requestNotificationPermissions();

      // Android initialization settings
      final AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings(config.androidAppIcon);

      // Process Android Actions from config
      List<AndroidNotificationAction> processedAndroidActions = [];
      for (var category in config.androidActionCategories!) {
        processedAndroidActions.addAll(await category.toAndroidNotificationActions());
      }

      // Process Darwin Actions
      final List<DarwinNotificationCategory> darwinNotificationCategories =
      config.darwinActionCategories!.map((category) => category.toDarwinNotificationCategory())
          .toList();

      // iOS initialization settings (update to use processed categories)
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinNotificationCategories,
      );

      // Update NotificationConfig to include these new actions
      _config = NotificationConfig(
        androidActions: processedAndroidActions,
        androidAppIcon: config.androidAppIcon,
        assetAppIcon: config.assetAppIcon,
        androidChannelId: config.androidChannelId,
        androidChannelName: config.androidChannelName,
        defaultActionName: config.defaultActionName,
        androidChannelDescription: config.androidChannelDescription,
        notificationSoundResource: config.notificationSoundResource,
        darwinActionCategories: config.darwinActionCategories,
        androidActionCategories: config.androidActionCategories,
      );
      // macOS initialization settings (similar to iOS)
      final DarwinInitializationSettings macOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinNotificationCategories,
      );

      // Linux initialization settings
      final LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(
        defaultActionName: config.defaultActionName,
        defaultIcon: AssetsLinuxIcon(config.assetAppIcon),
      );

      // Combine initialization settings for all platforms
      final InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macOSSettings,
        linux: linuxSettings,
      );

      // Initialize the notifications plugin
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
    }
  }

  // Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (_onForegroundMessage != null) {
        _onForegroundMessage!(message);
      }
      // Show local notification for foreground message
      _handleForegroundMessage(message);
    });

    // Handle when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && _onMessageOpenedApp != null) {
        _onMessageOpenedApp!(message);
      }
    });

    // Handle when app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (_onMessageOpenedApp != null) {
        _onMessageOpenedApp!(message);
      }
    });
  }

  // Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $_fcmToken');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        _fcmToken = token;
        if (kDebugMode) {
          print('FCM Token Refreshed: $token');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Extract notification data
    final notification = message.notification;
    final android = message.notification?.android;
    final apple = message.notification?.apple;

    if (notification != null) {
      // Show local notification
      await showNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data.toString(),
        imagePath: android?.imageUrl ?? apple?.imageUrl,
      );
    }
  }

  // Subscribe to FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Request FCM permission (iOS only)
  Future<bool> requestFCMPermission() async {
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return true;
  }

  // Delete FCM token
  Future<void> deleteFCMToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      // Platform-specific permission requests
      if (Platform.isAndroid) {
        // Request exact alarm permission for Android
        if (!await Permission.scheduleExactAlarm.isGranted) {
          final alarmResult = await Permission.scheduleExactAlarm.request();
          if (kDebugMode) {
            print('Exact Alarm Permission: $alarmResult');
          }
        }

        // Request notification permission for Android
        final notificationStatus = await Permission.notification.request();
        _notificationPermissionGranted =
            notificationStatus == PermissionStatus.granted;

        if (kDebugMode) {
          print('Notification Permission: $notificationStatus');
        }
      } else if (Platform.isIOS) {
        // For iOS, use FlutterLocalNotificationsPlugin's request method
        final result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        _notificationPermissionGranted = result ?? false;

        if (kDebugMode) {
          print('iOS Notification Permission: $result');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      _notificationPermissionGranted = false;
    }
  }

  // Configure local timezone
  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap event
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(notificationResponse);
    } else {
      // Default handling
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          if (kDebugMode) {
            print('Notification tapped: ${notificationResponse.payload}');
          }
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (kDebugMode) {
            print('Notification action tapped: ${notificationResponse.actionId}');
          }
          break;
      }
    }
  }

// Firebase background message handler
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize Firebase for background handler
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    if (kDebugMode) {
      print('Handling background message: ${message.messageId}');
    }
  }

  // Background notification handler
  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse notificationResponse) {
    // Handle background notification tap
    if (kDebugMode) {
      print('Background notification tapped: ${notificationResponse.payload}');
    }
  }

  // Utility method to handle different image types
  Future<String?> _processNotificationImage(String? imagePath) async {
    if (imagePath == null) return null;

    try {
      // Check if it's a network image
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // Download network image
        final response = await http.get(Uri.parse(imagePath));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_notification_image.png');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }

      // Check if it's an asset image
      if (path.extension(imagePath) != '') {
        // Load asset image
        final byteData = await rootBundle.load(imagePath);
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_notification_image.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      }

      // Assume it's a local file path
      return imagePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing notification image: $e');
      }
      return null;
    }
  }

// Unified notification method supporting both instant and scheduled notifications
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imagePath,
    bool withSound = true,

    // Scheduling parameters
    DateTime? scheduledTime,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode
        .exactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,

    // Additional notification customization
    Color? color,
    bool enableLights = false,
    Color? ledColor,
    int? ledOnMs,
    int? ledOffMs,
    Int64List? vibrationPattern,
  }) async {
    // Check if notification permission is granted
    if (!_notificationPermissionGranted) {
      await _requestNotificationPermissions();

      // If still not granted, return
      if (!_notificationPermissionGranted) {
        if (kDebugMode) {
          print('Notification permission not granted');
        }
        return;
      }
    }

    // Handle Android exact alarm permission for scheduled notifications
    if (scheduledTime != null && Platform.isAndroid) {
      try {
        // Check if the app can schedule exact alarms
        if (!await Permission.scheduleExactAlarm.isGranted) {
          // Request permission
          final result = await Permission.scheduleExactAlarm.request();

          if (result != PermissionStatus.granted) {
            // If permission is not granted, fall back to inexact scheduling
            androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

            if (kDebugMode) {
              print(
                  'Exact alarm permission not granted. Falling back to inexact scheduling.');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking/requesting exact alarm permission: $e');
        }
        // Fallback to inexact scheduling
        androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    } else if (Platform.isIOS) {
      // Handle iOS notification permissions
      try {
        // Check and request notification permission
        final notificationStatus = await Permission.notification.status;

        if (!notificationStatus.isGranted) {
          final result = await Permission.notification.request();

          if (result != PermissionStatus.granted) {
            if (kDebugMode) {
              print(
                  'Notification permission not granted. Scheduled notifications might not work.');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking/requesting notification permission on iOS: $e');
        }
      }
    }

    // Process the image path
    final processedImagePath = await _processNotificationImage(imagePath);

    // Android notification details now uses config.androidActions from the config
    final androidDetails = AndroidNotificationDetails(
      config.androidChannelId,
      config.androidChannelName,
      channelDescription: config.androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      sound: withSound ? RawResourceAndroidNotificationSound(config.notificationSoundResource) : null,
      playSound: withSound,
      styleInformation: processedImagePath != null
          ? BigPictureStyleInformation(FilePathAndroidBitmap(processedImagePath))
          : null,

      // Use androidActions from config
      actions: config.androidActions,
      color: color,
      enableLights: enableLights,
      ledColor: ledColor,
      ledOnMs: ledOnMs,
      ledOffMs: ledOffMs,
      vibrationPattern: vibrationPattern,
    );

    // iOS/macOS notification details
    final darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: withSound,
      attachments: processedImagePath != null
          ? [DarwinNotificationAttachment(processedImagePath)]
          : null,
    );

    // Linux notification details
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    // Combine notification details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    try {
      // Generate a unique notification ID
      final notificationId = DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000;

      if (scheduledTime == null) {
        // Show instant notification
        await _notificationsPlugin.show(
          notificationId,
          title,
          body,
          notificationDetails,
          payload: payload,
        );
      } else {
        // Schedule notification
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: androidScheduleMode,
          payload: payload,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing/scheduling notification: $e');
      }
      rethrow;
    }
  }
  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}