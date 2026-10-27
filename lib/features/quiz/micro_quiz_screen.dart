import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/core/services/notification_service.dart';

class MicroQuizScreen extends StatefulWidget {
  final String targetWordId;

  const MicroQuizScreen({super.key, required this.targetWordId});

  @override
  State<MicroQuizScreen> createState() => _MicroQuizScreenState();
}

class _MicroQuizScreenState extends State<MicroQuizScreen> {
  final LocalDatabase _database = LocalDatabase();
  VocabModel? _targetVocab;
  List<VocabModel> _options = [];
  bool _isLoading = true;
  int? _selectedIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final allVocabs = await _database.getAllVocabulary();
    _targetVocab = allVocabs.firstWhere((v) => v.id == widget.targetWordId, orElse: () => allVocabs.first);
    
    // Tạo 3 đáp án nhiễu
    final distractors = allVocabs
        .where((v) => v.id != _targetVocab!.id && v.meaning.isNotEmpty)
        .toList()
      ..shuffle();
    
    _options = [_targetVocab!, ...distractors.take(3)]..shuffle();
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleAnswer(int index) async {
    if (_isAnswered) return;
    
    final isCorrect = _options[index].id == _targetVocab!.id;
    final quality = isCorrect ? 3 : 0; // 3: Nhớ tốt, 0: Quên
    
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
    });

    // Cập nhật database và lên lịch thông báo tiếp theo
    final updatedVocab = _targetVocab!.updateAfterReview(quality);
    await _database.updateVocabulary(updatedVocab);
    
    // Hủy thông báo cũ và lên lịch mới
    await NotificationService().cancelNotification(_targetVocab!.id);
    if (updatedVocab.nextReviewDate != null) {
      await NotificationService().scheduleReviewNotification(
        wordId: updatedVocab.id,
        word: updatedVocab.word,
        scheduledDate: updatedVocab.nextReviewDate!,
      );
    }

    // Đóng màn hình sau 1.2 giây để người dùng kịp thấy kết quả
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8), // Nền mờ
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Từ này nghĩa là gì?',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _targetVocab!.word,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ...List.generate(4, (index) {
                          final option = _options[index];
                          final isSelected = _selectedIndex == index;
                          final isCorrect = option.id == _targetVocab!.id;
                          
                          Color borderColor = Colors.grey.shade300;
                          Color bgColor = Colors.white;
                          
                          if (_isAnswered) {
                            if (isCorrect) {
                              borderColor = AppColors.success;
                              bgColor = AppColors.success.withOpacity(0.1);
                            } else if (isSelected && !isCorrect) {
                              borderColor = AppColors.error;
                              bgColor = AppColors.error.withOpacity(0.1);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _handleAnswer(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option.meaning,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isCorrect && _isAnswered ? AppColors.success : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (_isAnswered && isCorrect)
                                      const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                                    if (_isAnswered && isSelected && !isCorrect)
                                      const Icon(Icons.cancel, color: AppColors.error, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
