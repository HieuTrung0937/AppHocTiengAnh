import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

class StudyStatistics extends StatelessWidget {
  const StudyStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kho từ vựng của tôi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Tổng đã lưu', '24', textColor, theme, isDark),
              const SizedBox(width: 12),
              _buildStatItem('Đã nắm vững', '6', AppColors.success, theme, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(isDark ? 0.3 : 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.priority_high, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Có 7 từ đang ở trạng thái "Hay quên"',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hãy dành ít phút hôm nay để ôn lại nhóm từ này.',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor, ThemeData theme, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.5 : 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: valueColor)),
          ],
        ),
      ),
    );
  }
}
