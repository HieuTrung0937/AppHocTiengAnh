import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoalCard extends StatefulWidget {
  const DailyGoalCard({super.key});

  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {
  final LocalDatabase _database = LocalDatabase();
  int _todayReviewed = 0;
  int _dailyGoal = 20; // Mặc định 20 từ/ngày
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
  }

  Future<void> _loadTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kiểm tra xem có phải ngày mới không để reset đếm
    final lastDate = prefs.getString('last_review_date') ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastDate != today) {
      _todayReviewed = 0;
      await prefs.setString('last_review_date', today);
      await prefs.setInt('today_reviewed_count', 0);
    } else {
      _todayReviewed = prefs.getInt('today_reviewed_count') ?? 0;
    }

    // Lấy mục tiêu đã lưu (mặc định 20)
    _dailyGoal = prefs.getInt('daily_goal') ?? 20;

    if (mounted) setState(() => _isLoading = false);
  }

  /// Gọi hàm này từ ReviewScreen sau khi user đánh giá xong 1 từ
  static Future<void> incrementReviewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString('last_review_date') ?? '';
    
    if (lastDate == today) {
      final current = prefs.getInt('today_reviewed_count') ?? 0;
      await prefs.setInt('today_reviewed_count', current + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progress = _dailyGoal > 0 ? (_todayReviewed / _dailyGoal).clamp(0.0, 1.0) : 0.0;
    final isCompleted = _todayReviewed >= _dailyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hôm nay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('Hoàn thành!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 8)
          else
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(Icons.emoji_events, size: 16, color: AppColors.success.withOpacity(0.8)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_todayReviewed / $_dailyGoal từ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                    Text(
                      isCompleted 
                          ? 'Tuyệt vời! ' 
                          : 'Còn ${_dailyGoal - _todayReviewed} từ nữa',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
