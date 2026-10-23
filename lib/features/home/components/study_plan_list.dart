import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

class StudyPlanList extends StatelessWidget {
  const StudyPlanList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final plans = [
      {
        'icon': Icons.warning_amber_rounded,
        'title': 'Ôn tập từ hay quên',
        'subtitle': '7 từ · Ưu tiên cao nhất',
        'color': AppColors.error,
      },
      {
        'icon': Icons.add_circle_outline,
        'title': 'Thêm từ mới từ OCR',
        'subtitle': 'Quét sách/đề thi để lưu nhanh',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Kiểm tra nhanh',
        'subtitle': '5 câu · Trắc nghiệm ngẫu nhiên',
        'color': AppColors.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Lộ trình hôm nay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {},
              child: const Text('Tùy chỉnh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...plans.map((plan) => _buildPlanItem(plan, colorScheme, isDark)),
      ],
    );
  }

  Widget _buildPlanItem(Map<String, dynamic> plan, ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (plan['color'] as Color).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(plan['icon'] as IconData, color: plan['color'] as Color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(plan['subtitle'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 16),
        ],
      ),
    );
  }
}
