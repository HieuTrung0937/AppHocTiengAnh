import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller quản lý thông tin người dùng (tên, lần đầu mở app)
class UserController extends ChangeNotifier {
  String _userName = '';
  bool _isFirstLaunch = true;

  String get userName => _userName;
  bool get isFirstLaunch => _isFirstLaunch;

  /// Khởi tạo: load dữ liệu từ SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? '';
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    notifyListeners();
  }

  /// Lưu tên người dùng
  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setBool('is_first_launch', false);
    _isFirstLaunch = false;
    notifyListeners();
  }

  /// Reset (dùng để test)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userName = '';
    _isFirstLaunch = true;
    notifyListeners();
  }
}
