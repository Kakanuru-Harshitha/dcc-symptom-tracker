// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          title: const Text('Dark mode'),
          value: s.darkMode,
          onChanged: (v) => s.setDark(v),
        ),
        const SizedBox(height:12),
        ListTile(
          title: const Text('Daily reminder at 09:00'),
          onTap: () => NotificationService()
              .scheduleDaily(const TimeOfDay(hour:9,minute:0)),
        ),
      ],
    );
  }
}
