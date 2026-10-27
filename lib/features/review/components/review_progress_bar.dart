import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// Thanh tiến trình hiển thị số từ đã ôn / tổng số từ
class ReviewProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalWords;
  final String category; // VD: "Môi trường · Ôn cá nhân"

  const ReviewProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalWords,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final progress = totalWords > 0 ? currentIndex / totalWords : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb và tiêu đề
        Text(
          'TỪ VỰNG TIẾNG ANH / THPT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Ôn từ vựng tiếng Anh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz, color: textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Category và số từ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
            Text(
              '$currentIndex / $totalWords từ',
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Thanh progress
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
