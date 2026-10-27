import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// Lịch học trong tuần hiển thị trạng thái hoàn thành từng ngày
class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final days = [
      {'label': 'T2', 'day': 5, 'done': true},
      {'label': 'T3', 'day': 6, 'done': true},
      {'label': 'T4', 'day': 7, 'done': false, 'isToday': true},
      {'label': 'T5', 'day': 8, 'done': false},
      {'label': 'T6', 'day': 9, 'done': false},
      {'label': 'T7', 'day': 10, 'done': false},
      {'label': 'CN', 'day': 11, 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          final isToday = day['isToday'] == true;
          final isDone = day['done'] == true;

          return Column(
            children: [
              Text(
                day['label'] as String,
                style: AppTypography.caption.copyWith(
                  color: isToday ? AppColors.primary : AppColors.textHint,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${day['day']}',
                    style: TextStyle(
                      color: isToday ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (isDone)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          );
        }).toList(),
      ),
    );
  }
}
