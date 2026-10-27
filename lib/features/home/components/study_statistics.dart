import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';

class StudyStatistics extends StatefulWidget {
  const StudyStatistics({super.key});

  @override
  State<StudyStatistics> createState() => _StudyStatisticsState();
}

class _StudyStatisticsState extends State<StudyStatistics> {
  final LocalDatabase _database = LocalDatabase();
  
  int _totalSaved = 0;
  int _mastered = 0;
  int _forgetCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final allVocabs = await _database.getAllVocabulary();
    final forgetVocabs = await _database.getVocabularyByGroup('Hay quên');
    
    int masteredCount = 0;
    int savedCount = 0;

    for (var vocab in allVocabs) {
      // Tổng đã lưu: Chỉ tính từ do người dùng thêm (không phải từ điển có sẵn)
      if (!vocab.isBuiltIn) {
        savedCount++;
      }
      
      // Đã nắm vững: errorRate thấp, chưa từng quên, và đã được ôn ít nhất 1 lần
      if (vocab.errorRate < 0.2 && vocab.forgetCount == 0 && vocab.lastReviewDate != null) {
        masteredCount++;
      }
    }

    if (mounted) {
      setState(() {
        _totalSaved = savedCount;
        _mastered = masteredCount;
        _forgetCount = forgetVocabs.length;
        _isLoading = false;
      });
    }
  }

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
          
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            Row(
              children: [
                _buildStatItem('Tổng đã lưu', '$_totalSaved', textColor, theme, isDark),
                const SizedBox(width: 12),
                _buildStatItem('Đã nắm vững', '$_mastered', AppColors.success, theme, isDark),
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
                        'Có $_forgetCount từ đang ở trạng thái "Hay quên"',
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
