import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// 4 nút đánh giá mức độ ghi nhớ (Giao diện tối giản, không hiển thị ngày)
class SpacedRepetitionActions extends StatelessWidget {
  // ✅ KHAI BÁO LẠI THAM SỐ ĐẦU VÀO
  final Function(int quality) onRate;

  const SpacedRepetitionActions({
    super.key, 
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;

    final actions = [
      {'label': 'Chưa nhớ', 'quality': 0, 'color': AppColors.error},
      {'label': 'Nhớ một phần', 'quality': 1, 'color': AppColors.warning},
      {'label': 'Đã nhớ', 'quality': 2, 'color': AppColors.primary},
      {'label': 'Nhớ tốt', 'quality': 3, 'color': AppColors.primary},
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
            final quality = action['quality'] as int;
            final color = action['color'] as Color;
            final isLast = quality == 3;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onRate(quality),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isLast ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        action['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isLast ? Colors.white : color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
