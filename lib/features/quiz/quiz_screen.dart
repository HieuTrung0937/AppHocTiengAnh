import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra')),
      body: const Center(
        child: Text('Màn hình Kiểm tra (Đang phát triển)', style: AppTypography.bodySmall),
      ),
    );
  }
}
