// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool darkMode = false;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    darkMode = p.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    darkMode = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool('darkMode', v);
    notifyListeners();
  }
}
