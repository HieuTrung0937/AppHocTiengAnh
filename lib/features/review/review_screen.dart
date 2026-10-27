import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/core/services/notification_service.dart';
import 'package:app_hoc_tieng_anh/features/review/components/review_progress_bar.dart';
import 'package:app_hoc_tieng_anh/features/review/components/flashcard_card.dart';
import 'package:app_hoc_tieng_anh/features/review/components/spaced_repetition_actions.dart';
import 'package:app_hoc_tieng_anh/features/vocabulary/components/add_edit_vocab_modal.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final LocalDatabase _database = LocalDatabase();
  List<VocabModel> _reviewList = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  int _masteredCount = 0;
  int _needReviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviewList();
  }

  Future<void> _loadReviewList() async {
    setState(() => _isLoading = true);
    final words = await _database.getWordsToReview(limit: 20);
    if (mounted) {
      setState(() {
        _reviewList = words;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRate(int quality) async {
    if (_currentIndex >= _reviewList.length) return;

    final currentVocab = _reviewList[_currentIndex];
    final updatedVocab = currentVocab.updateAfterReview(quality);
    await _database.updateVocabulary(updatedVocab);

    // ✅ Lên lịch thông báo ôn tập tiếp theo
    await NotificationService().cancelNotification(currentVocab.id);
    if (updatedVocab.nextReviewDate != null) {
      await NotificationService().scheduleReviewNotification(
        wordId: updatedVocab.id,
        word: updatedVocab.word,
        scheduledDate: updatedVocab.nextReviewDate!,
      );
    }

    if (quality >= 2) {
      _masteredCount++;
    } else {
      _needReviewCount++;
    }

    if (mounted) {
      setState(() => _currentIndex++);
    }
  }

  void _openAddWordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditVocabModal(
        onSave: (vocab) async {
          await _database.addVocabulary(vocab);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm từ vào danh sách ôn tập')),
            );
            _loadReviewList();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reviewList.isEmpty || _currentIndex >= _reviewList.length
                ? _buildEmptyState(textPrimary, textSecondary)
                : _buildReviewContent(textPrimary, textSecondary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWordModal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReviewContent(Color textPrimary, Color textSecondary) {
    final currentVocab = _reviewList[_currentIndex];
    final totalWords = _reviewList.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: ReviewProgressBar(
            currentIndex: _currentIndex + 1,
            totalWords: totalWords,
            category: 'Ôn tập từ vựng',
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FlashcardCard(vocab: currentVocab),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _currentIndex > 0
                        ? () => setState(() => _currentIndex--)
                        : null,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Trước'),
                    style: TextButton.styleFrom(foregroundColor: textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                SpacedRepetitionActions(onRate: _handleRate),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('$_masteredCount từ đã nhớ', style: TextStyle(fontSize: 12, color: textSecondary)),
                    const SizedBox(width: 16),
                    Icon(Icons.refresh, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('$_needReviewCount từ cần ôn lại', style: TextStyle(fontSize: 12, color: textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textPrimary, Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Chưa có từ vựng nào để ôn',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm từ vựng bạn muốn học để bắt đầu ôn tập.',
              style: TextStyle(fontSize: 14, color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openAddWordModal,
              icon: const Icon(Icons.add),
              label: const Text('Thêm từ vựng mới'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
