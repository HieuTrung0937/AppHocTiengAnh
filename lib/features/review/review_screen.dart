import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập')),
      body: const Center(
        child: Text('Màn hình Ôn tập Flashcard (Đang phát triển)', style: AppTypography.bodySmall),
      ),
    );
  }
}
