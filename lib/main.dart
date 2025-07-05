// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';                   // ← NEW
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';
import 'providers/log_provider.dart';
import 'providers/med_provider.dart';
import 'models/metrics_provider.dart';                           // ← NEW
import 'models/daily_metrics.dart';                                 // ← NEW
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/log_symptom_screen.dart';
import 'screens/med_edit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive setup for DailyMetrics ───────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(DailyMetricsAdapter());
  await Hive.openBox<DailyMetrics>('metrics');
  // ──────────────────────────────────────────────────────────────

  await DatabaseService().init();
  await NotificationService().init();

  runApp(const SymptomTrackerApp());
}

class SymptomTrackerApp extends StatelessWidget {
  const SymptomTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()..load()),
        ChangeNotifierProvider(create: (_) => MedProvider()..load()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),    // ← NEW
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Symptom Tracker',
          theme: AppTheme.build(settings.darkMode),
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/log': (_) => const LogSymptomScreen(),
            '/med_edit': (_) => const MedEditScreen(),
          },
        ),
      ),
    );
  }
}
