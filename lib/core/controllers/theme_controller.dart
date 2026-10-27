import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller quản lý trạng thái Theme (Sáng/Tối)
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo: đọc trạng thái theme đã lưu từ thiết bị
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode');
    
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system; // Mặc định theo hệ thống
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Đảo trạng thái Sáng <-> Tối và lưu lại
  Future<void> toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
    
    notifyListeners(); // Báo hiệu cho ListenableBuilder rebuild
  }

  /// Đặt chế độ cụ thể (dùng cho Settings)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
    
    notifyListeners();
  }
}
