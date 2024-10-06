import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('assets/launcher.png'),
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null,
            linux: initializationSettingsLinux);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
    final jakarta = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(jakarta);
  }

  Future<void> showDailyReminder() async {
    Timer.periodic(Duration(hours: 24), (timer) async {
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(now.year, now.month, now.day, 20, 45);
      if (now.isAfter(scheduledTime)) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }
      final duration = scheduledTime.difference(now);

      await Future.delayed(duration);
      await flutterLocalNotificationsPlugin.show(
        1,
        'Pengingat Keuangan',
        'Apakah kamu sudah mencatat keuanganmu hari ini?',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminder',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          linux: LinuxNotificationDetails(
            icon: AssetsLinuxIcon('assets/launcher.png'),
          ),
        ),
        payload: 'homepage',
      );
    });
  }

  Future<void> showTransactionNotification({
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'transaction_channel',
          'Transaction Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(
          icon: AssetsLinuxIcon('assets/launcher.png'),
        ),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf2045() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 45);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}