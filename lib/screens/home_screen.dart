// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'trends_screen.dart';
import 'med_list_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  static const _titles = [
    'Calendar',
    'Trends',
    'Medications',
    'Report',
    'Settings',
  ];

  static const _screens = [
    CalendarScreen(),
    TrendsScreen(),
    MedListScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_idx])),
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Trends'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'Meds'),
          BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      // ← No more FAB here; CalendarScreen will show its own
    );
  }
}
