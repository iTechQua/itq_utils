import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification tap callback
  void Function(NotificationResponse)? _onNotificationTapCallback;

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    initialize();
  }

  // Notification permission status
  bool _notificationPermissionGranted = false;

  // Getter for notification permission status
  bool get isNotificationPermissionGranted => _notificationPermissionGranted;

  // Initialize notification service
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    try {
      // Store the custom notification tap callback
      _onNotificationTapCallback = onNotificationTap;
      // Ensure the app is initialized for notifications
      await _configureLocalTimeZone();

      // Request notification permissions
      await _requestNotificationPermissions();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('app_icon');

      // iOS/macOS notification categories
      final List<DarwinNotificationCategory> darwinNotificationCategories = [
        DarwinNotificationCategory(
          'text_category',
          actions: [
            DarwinNotificationAction.text(
              'text_1',
              'Reply',
              buttonTitle: 'Send',
              placeholder: 'Type a message',
            ),
          ],
        ),
        DarwinNotificationCategory(
          'plain_category',
          actions: [
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: {DarwinNotificationActionOption.destructive},
            ),
          ],
        ),
      ];

      // iOS initialization settings
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: darwinNotificationCategories,
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
        defaultActionName: 'Open notification',
        defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
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
      if (imagePath.startsWith('assets/')) {
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

  // Show an instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    String? imagePath,
    bool withSound = true,
    String? soundResourceName, // Optional custom sound
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

    // Process the image path
    final processedImagePath = await _processNotificationImage(imagePath);

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      sound: withSound
          ? const RawResourceAndroidNotificationSound('notification_sound')
          : null,
      playSound: withSound,
      styleInformation: processedImagePath != null
          ? BigPictureStyleInformation(FilePathAndroidBitmap(processedImagePath))
          : null,
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
      // Show the notification
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
    }
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    String? imagePath,
    bool withSound = true,
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
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

    // Check and request exact alarm permissions for Android
    if (Platform.isAndroid) {
      try {
        // Check if the app can schedule exact alarms
        if (!await Permission.scheduleExactAlarm.isGranted) {
          // Request permission
          final result = await Permission.scheduleExactAlarm.request();

          if (result != PermissionStatus.granted) {
            // If permission is not granted, fall back to inexact scheduling
            androidScheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

            if (kDebugMode) {
              print('Exact alarm permission not granted. Falling back to inexact scheduling.');
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
    }

    // Process the image path
    final processedImagePath = await _processNotificationImage(imagePath);

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      sound: withSound
          ? const RawResourceAndroidNotificationSound('notification_sound')
          : null,
      playSound: withSound,
      styleInformation: processedImagePath != null
          ? BigPictureStyleInformation(FilePathAndroidBitmap(processedImagePath))
          : null,
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
      // Schedule the notification
      await _notificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
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