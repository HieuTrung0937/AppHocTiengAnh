import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';

/// Card hiển thị câu hỏi kiểm tra với 4 đáp án
class QuestionCard extends StatefulWidget {
  final int questionNumber;
  final String mode; // 'Chọn nghĩa' / 'Điền từ' / 'Luyện nghe'
  final VocabModel targetVocab; // Từ đúng
  final List<VocabModel> options; // 4 đáp án (bao gồm từ đúng)
  final VoidCallback onCheckAnswer;
  final Function(bool isCorrect)? onAnswered;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.mode,
    required this.targetVocab,
    required this.options,
    required this.onCheckAnswer,
    this.onAnswered,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int? _selectedIndex;
  bool _isAnswered = false;
  int? _correctIndex;

  @override
  void initState() {
    super.initState();
    // Tìm index của đáp án đúng
    _correctIndex = widget.options.indexWhere((v) => v.id == widget.targetVocab.id);
  }

  void _checkAnswer() {
    if (_selectedIndex == null) return;
    
    final isCorrect = _selectedIndex == _correctIndex;
    setState(() {
      _isAnswered = true;
    });
    widget.onAnswered?.call(isCorrect);
  }

  String _buildQuestionText() {
    switch (widget.mode) {
      case 'Điền từ':
        return 'We should protect the [chỗ trống] by reducing waste.';
      case 'Luyện nghe':
        return 'Hãy nghe và chọn từ đúng:';
      case 'Chọn nghĩa':
      default:
        return 'Chọn nghĩa đúng của từ:';
    }
  }

  String _getOptionText(VocabModel vocab) {
    switch (widget.mode) {
      case 'Chọn nghĩa':
        return vocab.meaning;
      case 'Điền từ':
      case 'Luyện nghe':
      default:
        return vocab.word;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final cardBgColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Câu số + chế độ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${widget.questionNumber}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
              ),
              Text(
                widget.mode,
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Câu hỏi
          Text(
            _buildQuestionText(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary, height: 1.4),
          ),
          const SizedBox(height: 20),

          // 4 đáp án
          ...List.generate(widget.options.length, (index) {
            final option = widget.options[index];
            final isSelected = _selectedIndex == index;
            final isCorrectOption = index == _correctIndex;
            
            Color borderColor = theme.colorScheme.outlineVariant.withOpacity(0.3);
            Color bgColor = cardBgColor;
            Color radioColor = textSecondary;
            
            if (_isAnswered) {
              if (isCorrectOption) {
                borderColor = AppColors.success;
                bgColor = AppColors.success.withOpacity(0.1);
                radioColor = AppColors.success;
              } else if (isSelected && !isCorrectOption) {
                borderColor = AppColors.error;
                bgColor = AppColors.error.withOpacity(0.1);
                radioColor = AppColors.error;
              }
            } else if (isSelected) {
              borderColor = AppColors.primary;
              bgColor = AppColors.primary.withOpacity(0.08);
              radioColor = AppColors.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _isAnswered ? null : () => setState(() => _selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: radioColor, width: 2),
                          color: isSelected ? radioColor : Colors.transparent,
                        ),
                        child: isSelected
                            ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getOptionText(option),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Nút Kiểm tra đáp án
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnswered || _selectedIndex == null ? null : _checkAnswer,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Kiểm tra đáp án'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
