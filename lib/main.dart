import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/app/app.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo database trước khi chạy app
  await LocalDatabase().init();

  runApp(const App());
}
