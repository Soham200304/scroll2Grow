import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;

  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await androidPlugin?.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> scheduleReminder({
    required int intervalHours,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scroll2grow_reminders',
      'Scroll2Grow Reminders',
      channelDescription: 'Reminders to take a break and refocus.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    final interval = switch (intervalHours) {
      1 => RepeatInterval.hourly,
      24 => RepeatInterval.daily,
      _ => RepeatInterval.hourly,
    };

    await _notifications.periodicallyShow(
      _reminderId,
      'Scroll2Grow',
      'Ready to focus? Start Now.',
      interval,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'home',
    );
  }

  Future<void> cancelReminders() async {
    await _notifications.cancel(_reminderId);
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'scroll2grow_reminders',
      'Scroll2Grow Reminders',
      channelDescription: 'Reminders to take a break and refocus.',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      1002,
      'Scroll2Grow',
      'Ready to focus? Start Now.',
      const NotificationDetails(android: androidDetails),
      payload: 'home',
    );
  }
}