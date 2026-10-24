import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// Box thông tin提示 cuối màn hình quiz
class QuizTipBox extends StatelessWidget {
  const QuizTipBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final bgColor = theme.colorScheme.surfaceContainerHighest?.withOpacity(0.5) ?? AppColors.surfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Từ chưa chắc sẽ được ưu tiên ôn tập',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Từ trả lời sai sẽ được thêm vào danh sách cần ôn.',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
