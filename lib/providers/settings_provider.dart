import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit { kg, lb }

class SettingsProvider extends ChangeNotifier {
  WeightUnit _weightUnit = WeightUnit.kg;
  static const String _weightUnitKey = 'weight_unit';

  WeightUnit get weightUnit => _weightUnit;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final unitIndex = prefs.getInt(_weightUnitKey) ?? 0;
    _weightUnit = WeightUnit.values[unitIndex];
    notifyListeners();
  }

  void setWeightUnit(WeightUnit unit) async {
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_weightUnitKey, unit.index);
    notifyListeners();
  }

  double convertWeight(double weight, WeightUnit from, WeightUnit to) {
    if (from == to) return weight;
    if (from == WeightUnit.kg && to == WeightUnit.lb) {
      return weight * 2.20462;
    } else {
      return weight / 2.20462;
    }
  }
}