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

// Enum for notification types
enum NotificationActionType {
  plain,
  text,
}

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

  Future<AndroidNotificationAction?> toAndroidNotificationAction() async {
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
        if (options?['destructive'] == true) {
          actionOptions.add(DarwinNotificationActionOption.destructive);
        }
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

  Future<String?> _processActionIcon(String iconPath) async {
    try {
      if (iconPath.startsWith('http')) {
        final response = await http.get(Uri.parse(iconPath));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_action_icon.png');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }

      if (path.extension(iconPath).isNotEmpty) {
        final byteData = await rootBundle.load(iconPath);
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/temp_action_icon.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      }

      return iconPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing action icon: $e');
      }
      return null;
    }
  }
}

// Notification Category class
class NotificationCategory {
  final String identifier;
  final List<NotificationAction> actions;

  const NotificationCategory({
    required this.identifier,
    required this.actions,
  });

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

  DarwinNotificationCategory toDarwinNotificationCategory() {
    return DarwinNotificationCategory(
      identifier,
      actions: actions.map((action) => action.toDarwinNotificationAction()).toList(),
    );
  }
}

// Updated NotificationConfig
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

  const NotificationConfig({
    this.androidAppIcon = '@mipmap/ic_launcher',
    this.assetAppIcon = 'assets/app_icon.png',
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

// Main NotificationService class
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late NotificationConfig _config;

  void Function(RemoteMessage)? _onForegroundMessage;
  void Function(RemoteMessage)? _onMessageOpenedApp;
  void Function(NotificationResponse)? _onNotificationTapCallback;
  String? _fcmToken;
  bool _notificationPermissionGranted = false;

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isNotificationPermissionGranted => _notificationPermissionGranted;
  NotificationConfig get config => _config;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService({NotificationConfig? config}) {
    if (config != null) {
      _instance._updateConfig(config);
    }
    return _instance;
  }

  NotificationService._internal() {
    _config = const NotificationConfig();
    initialize();
  }

  void _updateConfig(NotificationConfig newConfig) {
    _config = newConfig;
  }

  // Initialize notification service
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
    void Function(RemoteMessage)? onForegroundMessage,
    void Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _onNotificationTapCallback = onNotificationTap;
      _onForegroundMessage = onForegroundMessage;
      _onMessageOpenedApp = onMessageOpenedApp;

      await Future.wait([
        _configureFCM(),
        _getFCMToken(),
        _configureLocalTimeZone(),
        _requestNotificationPermissions(),
      ]);

      // Initialize platform-specific settings
      final androidSettings = AndroidInitializationSettings(_config.androidAppIcon);

      // Process Android Actions
      List<AndroidNotificationAction> processedAndroidActions = [];
      if (_config.androidActionCategories != null) {
        for (var category in _config.androidActionCategories!) {
          processedAndroidActions.addAll(await category.toAndroidNotificationActions());
        }
      }

      // Process Darwin Categories
      final List<DarwinNotificationCategory> darwinCategories = [];
      if (_config.darwinActionCategories != null) {
        darwinCategories.addAll(
          _config.darwinActionCategories!
              .map((category) => category.toDarwinNotificationCategory())
              .toList(),
        );
      }

      final darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinCategories,
      );

      final linuxSettings = LinuxInitializationSettings(
        defaultActionName: _config.defaultActionName,
        defaultIcon: AssetsLinuxIcon(_config.assetAppIcon),
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
      rethrow;
    }
  }

  // Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _onForegroundMessage?.call(message);
      _handleForegroundMessage(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp?.call(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onMessageOpenedApp?.call(message);
    });
  }

  // Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

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

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data.toString(),
        imagePath: notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
    }
  }

  // Firebase background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    if (kDebugMode) {
      print('Handling background message: ${message.messageId}');
    }
  }

  // Process notification image
  Future<String?> _processNotificationImage(String? imagePath) async {
    if (imagePath == null) return null;

    try {
      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/notification_image.png');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }

      if (path.extension(imagePath).isNotEmpty) {
        final byteData = await rootBundle.load(imagePath);
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/notification_image.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        return file.path;
      }

      return imagePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing image: $e');
      }
      return null;
    }
  }

  // FCM Topic Management
  Future<void> subscribeToTopic(String topic) => _firebaseMessaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _firebaseMessaging.unsubscribeFromTopic(topic);
  Future<void> deleteFCMToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
  }

  // Configure timezone
  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) return;

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // Request permissions
  // Request FCM permission
  Future<bool> requestFCMPermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android, we need both notification and exact alarm permissions
        final notificationStatus = await Permission.notification.request();
        if (!await Permission.scheduleExactAlarm.isGranted) {
          await Permission.scheduleExactAlarm.request();
        }
        _notificationPermissionGranted = notificationStatus == PermissionStatus.granted;
      } else if (Platform.isIOS) {
        // For iOS, request FCM permissions
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          criticalAlert: false,
          announcement: false,
          carPlay: false,
        );
        _notificationPermissionGranted =
            settings.authorizationStatus == AuthorizationStatus.authorized;
      }
      return _notificationPermissionGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting FCM permission: $e');
      }
      return false;
    }
  }

  // Internal permission request method
  Future<void> _requestNotificationPermissions() async {
    try {
      final permissionGranted = await requestFCMPermission();
      _notificationPermissionGranted = permissionGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permissions: $e');
      }
      _notificationPermissionGranted = false;
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    _onNotificationTapCallback?.call(response);
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse response) {
    if (kDebugMode) {
      print('Background notification tapped: ${response.payload}');
    }
  }

  // Show notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imagePath,
    bool withSound = true,
    DateTime? scheduledTime,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
    Color? color,
    bool enableLights = false,
    Color? ledColor,
    int? ledOnMs,
    int? ledOffMs,
    Int64List? vibrationPattern,
  }) async {
    if (!_notificationPermissionGranted) {
      await _requestNotificationPermissions();
      if (!_notificationPermissionGranted) return;
    }

    try {
      final String? processedImagePath = await _processNotificationImage(imagePath);

      final androidDetails = AndroidNotificationDetails(
        _config.androidChannelId,
        _config.androidChannelName,
        channelDescription: _config.androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        sound: withSound ? RawResourceAndroidNotificationSound(_config.notificationSoundResource) : null,
        playSound: withSound,
        styleInformation: processedImagePath != null
            ? BigPictureStyleInformation(FilePathAndroidBitmap(processedImagePath))
            : null,
        actions: _config.androidActions,
        color: color,
        enableLights: enableLights,
        ledColor: ledColor,
        ledOnMs: ledOnMs,
        ledOffMs: ledOffMs,
        vibrationPattern: vibrationPattern,
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: withSound,
        sound: withSound ? _config.notificationSoundResource : null,
        attachments: processedImagePath != null
            ? [DarwinNotificationAttachment(processedImagePath)]
            : null,
      );

      final linuxDetails = const LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (scheduledTime == null) {
        await _notificationsPlugin.show(
          id,
          title,
          body,
          notificationDetails,
          payload: payload,
        );
      } else {
        if (Platform.isAndroid) {
          final hasExactAlarmPermission = await Permission.scheduleExactAlarm.isGranted;
          if (!hasExactAlarmPermission) {
            androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
          }
        }

        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: androidScheduleMode,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
          payload: payload,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing/scheduling notification: $e');
      }
      rethrow;
    }
  }

  // Utility methods
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}