import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static const String _enabledKey = 'notifications_enabled';
  static const String _intervalKey = 'notification_interval_hours';

  Future<bool> getEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<int> getIntervalHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? 1;
  }

  Future<void> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  Future<void> saveIntervalHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, hours);
  }
}