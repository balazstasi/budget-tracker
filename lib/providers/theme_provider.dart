import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;
  final _prefs = SharedPreferences.getInstance();

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  static const List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
  ];

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await _prefs;
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await _prefs;
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  ThemeData get _lightTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        error: Colors.red,
        surface: Colors.white,
        onSurface: Colors.black87,
        onSurfaceVariant: Colors.black54,
        outline: Colors.grey.shade300,
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
    );
  }

  ThemeData get _darkTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        error: Colors.redAccent,
        surface: Colors.grey.shade900,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        outline: Colors.grey.shade800,
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        color: Colors.grey.shade900,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey.shade900,
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
} 