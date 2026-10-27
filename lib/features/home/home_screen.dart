import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/theme_controller.dart';
import 'package:app_hoc_tieng_anh/core/controllers/user_controller.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/features/home/components/greeting_header.dart';
import 'package:app_hoc_tieng_anh/features/home/components/daily_progress_card.dart';
import 'package:app_hoc_tieng_anh/features/home/components/quick_actions.dart';
import 'package:app_hoc_tieng_anh/features/home/components/study_statistics.dart';
import 'package:app_hoc_tieng_anh/features/settings/settings_screen.dart';
import 'package:app_hoc_tieng_anh/features/review/review_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final UserController userController;

  const HomeScreen({
    super.key,
    required this.themeController,
    required this.userController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDatabase _database = LocalDatabase();
  List<VocabModel> _dueVocabs = [];
  bool _isLoadingDue = true;

  @override
  void initState() {
    super.initState();
    _loadDueVocabs();
  }

  Future<void> _loadDueVocabs() async {
    // Lấy 5 từ cần ôn hôm nay
    final allDue = await _database.getWordsToReview(limit: 5);
    if (mounted) {
      setState(() {
        _dueVocabs = allDue.take(5).toList();
        _isLoadingDue = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(
                userController: widget.userController,
                onSettingsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        themeController: widget.themeController,
                        userController: widget.userController,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Card tiến độ hàng ngày
              const DailyProgressCard(),
              const SizedBox(height: 20),

              // Hành động nhanh (OCR / Thêm từ)
              const QuickActions(),
              const SizedBox(height: 20),

              // Thống kê kho từ
              const StudyStatistics(),
              const SizedBox(height: 20),

              // ✅ THAY THẾ: Quick Review Widget (Ôn tập nhanh)
              _buildQuickReviewWidget(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReviewWidget(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary =
        theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary =
        theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final cardBgColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cần ôn hôm nay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              if (!_isLoadingDue && _dueVocabs.isNotEmpty)
                Text(
                  '${_dueVocabs.length} từ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingDue)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_dueVocabs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 40,
                      color: AppColors.success.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tuyệt vời! Bạn đã ôn xong hết từ hôm nay.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ..._dueVocabs
                    .map(
                      (vocab) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: vocab.forgetCount >= 3
                                    ? AppColors.error
                                    : AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vocab.word,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              vocab.meaning,
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to Review Screen hoặc mở modal ôn nhanh
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReviewScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Bắt đầu ôn tập ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
