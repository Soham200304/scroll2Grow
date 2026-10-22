import 'package:flutter/material.dart';

import 'package:scrool2grow/features/notifications/services/NotificationService.dart';
import 'package:scrool2grow/features/notifications/services/NotificationPreferencesService.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends State<NotificationSettingsView> {
  final NotificationPreferencesService _preferences =
  NotificationPreferencesService();

  bool _enabled = false;
  int _intervalHours = 1;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final enabled = await _preferences.getEnabled();
    final interval = await _preferences.getIntervalHours();

    if (!mounted) return;

    setState(() {
      _enabled = enabled;
      _intervalHours = interval;
      _loading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _saving = true);

    try {
      if (value) {
        final granted =
        await NotificationService.instance.requestPermission();

        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please allow notifications in Android settings.',
                ),
              ),
            );
          }
          return;
        }

        await NotificationService.instance.scheduleReminder(
          intervalHours: _intervalHours,
        );
      } else {
        await NotificationService.instance.cancelReminders();
      }

      await _preferences.saveEnabled(value);

      if (mounted) {
        setState(() => _enabled = value);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update notification settings.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _changeInterval(int? hours) async {
    if (hours == null) return;

    setState(() => _saving = true);

    try {
      await _preferences.saveIntervalHours(hours);

      if (_enabled) {
        await NotificationService.instance.scheduleReminder(
          intervalHours: hours,
        );
      }

      if (mounted) {
        setState(() => _intervalHours = hours);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update reminder interval.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Enable notifications'),
              subtitle: const Text(
                'Receive reminders to pause and refocus.',
              ),
              value: _enabled,
              onChanged: _saving ? null : _toggleNotifications,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reminder interval',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _intervalHours,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Every hour'),
                      ),
                      DropdownMenuItem(
                        value: 24,
                        child: Text('Once a day'),
                      ),
                    ],
                    onChanged: _saving ? null : _changeInterval,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reminders may be delayed by Android battery settings.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active_outlined),
              title: Text('Reminder message'),
              subtitle: Text(
                'Scroll2Grow\nReady to focus? Start Now.',
              ),
            ),
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}