import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

class QuizModeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const QuizModeSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  // SỬA LỖI: Thêm const vào đây
  static const List<String> _modes = ['Chọn nghĩa', 'Điền từ', 'Luyện nghe'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest?.withOpacity(0.5) ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_modes.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _modes[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
