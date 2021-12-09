import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  ThemeProvider({
    ThemeMode themeMode = ThemeMode.light,
  }) : _themeMode = themeMode;

  void toggleMode() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
