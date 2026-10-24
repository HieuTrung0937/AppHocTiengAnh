import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// 4 nút đánh giá mức độ ghi nhớ theo Spaced Repetition
class SpacedRepetitionActions extends StatelessWidget {
  final Function(int quality) onRate;

  const SpacedRepetitionActions({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary =
        theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;

    final actions = [
      {
        'label': 'Chưa nhớ',
        // 'interval': 'Sáng mai',
        'quality': 0,
        'color': AppColors.error,
      },
      {
        'label': 'Nhớ một phần',
        // 'interval': '2 ngày',
        'quality': 1,
        'color': AppColors.warning,
      },
      {
        'label': 'Đã nhớ',
        // 'interval': '1 tuần',
        'quality': 2,
        'color': AppColors.primary,
      },
      {
        'label': 'Nhớ tốt',
        // 'interval': '2 tuần',
        'quality': 3,
        'color': AppColors.primary,
      },
    ];

    return Column(
      children: [
        Text(
          'Bạn nhớ từ này đến mức nào?',
          style: TextStyle(fontSize: 14, color: textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildActionButton(
                  label: action['label'] as String,
                  // interval: action['interval'] as String,
                  quality: action['quality'] as int,
                  color: action['color'] as Color,
                  isLast: action['quality'] == 3,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    // required String interval,
    required int quality,
    required Color color,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: () => onRate(quality),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isLast ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isLast ? Colors.white : color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            //   Text(
            //     // interval,
            //     style: TextStyle(
            //       fontSize: 10,
            //       color: isLast
            //           ? Colors.white.withOpacity(0.8)
            //           : color.withOpacity(0.7),
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
          ],
        ),
      ),
    );
  }
}
