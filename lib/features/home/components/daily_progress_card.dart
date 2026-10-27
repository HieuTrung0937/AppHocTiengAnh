import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';

class DailyProgressCard extends StatefulWidget {
  const DailyProgressCard({super.key});

  @override
  State<DailyProgressCard> createState() => _DailyProgressCardState();
}

class _DailyProgressCardState extends State<DailyProgressCard> {
  final LocalDatabase _database = LocalDatabase();
  int _dueCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final count = await _database.getDueReviewCount();
    if (mounted) {
      setState(() {
        _dueCount = count;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Từ vựng cần ôn hôm nay',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const SizedBox(height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_dueCount',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'từ cần ôn',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                const SizedBox(height: 8),
                const Text(
                  'Hệ thống tự động ưu tiên từ dựa trên thuật toán Spaced Repetition.',
                  style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.2 : 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
