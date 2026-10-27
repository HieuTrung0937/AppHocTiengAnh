import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/app/app.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/navigation_key.dart';
import 'package:app_hoc_tieng_anh/core/services/notification_service.dart';
import 'package:app_hoc_tieng_anh/features/quiz/micro_quiz_screen.dart';

// Global key để điều hướng từ notification

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase().init();
  
  // Khởi tạo notification service
  await NotificationService().init((String? payload) {
    if (payload != null && navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => MicroQuizScreen(targetWordId: payload),
        ),
      );
    }
  });

  runApp(const App());
}
