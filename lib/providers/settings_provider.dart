import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _showOverallProgressKey = 'show_overall_progress';
  static const String _textSizeScaleKey = 'text_size_scale';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _highContrastKey = 'high_contrast';

  bool _showOverallProgress = true;
  double _textSizeScale = 1.0;
  bool _isDarkMode = false;
  bool _highContrast = false;
  bool _isLoading = false;

  bool get showOverallProgress => _showOverallProgress;
  double get textSizeScale => _textSizeScale;
  bool get isDarkMode => _isDarkMode;
  bool get highContrast => _highContrast;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _showOverallProgress = prefs.getBool(_showOverallProgressKey) ?? true;
      _textSizeScale = prefs.getDouble(_textSizeScaleKey) ?? 1.0;
      _isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
      _highContrast = prefs.getBool(_highContrastKey) ?? false;
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setShowOverallProgress(bool value) async {
    if (_showOverallProgress != value) {
      _showOverallProgress = value;
      await _savePreference(_showOverallProgressKey, value);
      notifyListeners();
    }
  }

  Future<void> setTextSizeScale(double value) async {
    if (_textSizeScale != value) {
      _textSizeScale = value;
      await _savePreference(_textSizeScaleKey, value);
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      await _savePreference(_isDarkModeKey, value);
      notifyListeners();
    }
  }

  Future<void> setHighContrast(bool value) async {
    if (_highContrast != value) {
      _highContrast = value;
      await _savePreference(_highContrastKey, value);
      notifyListeners();
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving preference $key: $e');
    }
  }

  void resetToDefaults() async {
    _showOverallProgress = true;
    _textSizeScale = 1.0;
    _isDarkMode = false;
    _highContrast = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_showOverallProgressKey);
      await prefs.remove(_textSizeScaleKey);
      await prefs.remove(_isDarkModeKey);
      await prefs.remove(_highContrastKey);
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }

    notifyListeners();
  }
}