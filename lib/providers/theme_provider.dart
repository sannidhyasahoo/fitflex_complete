// providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // IMPORTANT: This import MUST be here for textTheme

class ThemeProvider extends ChangeNotifier {
  // Keys for SharedPreferences
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  ThemeMode _themeMode = ThemeMode.system;
  // Default primary color: match your app's initial primary color (from FitFlexApp)
  Color _primarySeedColor = const Color(
    0xFF6C63FF,
  ); // Your original purple-blue

  ThemeMode get themeMode => _themeMode;
  Color get primarySeedColor => _primarySeedColor;

  ThemeProvider() {
    _loadThemeSettings(); // Load settings when provider is created
  }

  // Unified method to load all theme settings from SharedPreferences
  void _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load ThemeMode
    final int? themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null &&
        themeModeIndex >= 0 &&
        themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    } else {
      _themeMode = ThemeMode.system; // Default to system if not found
    }

    // Load Primary Color
    final int? primaryColorValue = prefs.getInt(_primaryColorKey);
    if (primaryColorValue != null) {
      _primarySeedColor = Color(primaryColorValue);
    } else {
      _primarySeedColor = const Color(
        0xFF6C63FF,
      ); // Default to your app's starting primary color
    }
    notifyListeners(); // Notify UI once all settings are loaded
  }

  // Set theme mode and save to SharedPreferences
  void setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  // Set primary seed color and save to SharedPreferences
  void setPrimarySeedColor(Color color) async {
    if (_primarySeedColor == color) return;
    _primarySeedColor = color;
    notifyListeners(); // Trigger UI rebuild with the new color
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _primaryColorKey,
      color.value,
    ); // Store the color's int value
  }

  // Light theme data getter for MaterialApp
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeedColor, // Use the selected primary color
        brightness: Brightness.light,
      ),
      textTheme:
          GoogleFonts.interTextTheme(), // Apply Inter font to light theme
      // You can add more light theme customizations here like appBarTheme, buttonTheme etc.
    );
  }

  // Dark theme data getter for MaterialApp
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primarySeedColor, // Use the selected primary color
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ), // Apply Inter font to dark theme, merging with default dark theme text
      // You can add more dark theme customizations here
    );
  }
}
