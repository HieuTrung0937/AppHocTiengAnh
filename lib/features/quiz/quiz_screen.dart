import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/features/quiz/components/quiz_mode_selector.dart';
import 'package:app_hoc_tieng_anh/features/quiz/components/quiz_progress_card.dart';
import 'package:app_hoc_tieng_anh/features/quiz/components/question_card.dart';
import 'package:app_hoc_tieng_anh/features/quiz/components/quiz_tip_box.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final LocalDatabase _database = LocalDatabase();
  int _selectedMode = 0;
  
  List<VocabModel> _allVocabs = []; // Lưu toàn bộ từ để sinh đáp án nhiễu
  List<VocabModel> _quizList = [];
  
  int _currentQuestion = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isLoading = true;
  bool _isFinished = false;

  final List<String> _modeNames = ['Chọn nghĩa', 'Điền từ', 'Luyện nghe'];

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() => _isLoading = true);
    
    // Lấy toàn bộ từ vựng 1 lần duy nhất
    _allVocabs = await _database.getAllVocabulary();
    _allVocabs.shuffle();
    
    // Lấy 10 từ cho bài quiz (hoặc ít hơn nếu DB không đủ)
    _quizList = _allVocabs.take(10).toList();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentQuestion = 0;
        _correctCount = 0;
        _wrongCount = 0;
        _isFinished = false;
      });
    }
  }

  /// Sinh 4 đáp án (1 đúng + 3 sai ngẫu nhiên) - BỎ ASYNC để chạy đồng bộ
  List<VocabModel> _generateOptions(VocabModel correct) {
    final wrongOptions = _allVocabs
        .where((v) => v.id != correct.id)
        .toList()
      ..shuffle();
    
    final options = [correct, ...wrongOptions.take(3)];
    options.shuffle();
    return options;
  }

  Future<void> _handleAnswered(bool isCorrect) async {
    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
      final currentVocab = _quizList[_currentQuestion];
      final updated = currentVocab.updateAfterReview(0);
      await _database.updateVocabulary(updated);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          if (_currentQuestion >= _quizList.length) {
            _isFinished = true;
          }
        });
      }
    });
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
            : _isFinished
                ? _buildResultScreen(textPrimary, textSecondary)
                : _buildQuizContent(textPrimary, textSecondary),
      ),
    );
  }

  Widget _buildQuizContent(Color textPrimary, Color textSecondary) {
    // Sinh đáp án ngay trong build method (vì hàm giờ đã đồng bộ)
    final currentOptions = _generateOptions(_quizList[_currentQuestion]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KIỂM TRA / TIẾNG ANH THPT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kiểm tra từ vựng hôm nay',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          QuizModeSelector(
            selectedIndex: _selectedMode,
            onSelected: (index) {
              setState(() => _selectedMode = index);
              _generateQuiz();
            },
          ),
          const SizedBox(height: 20),

          QuizProgressCard(
            currentQuestion: _currentQuestion + 1,
            totalQuestions: _quizList.length,
          ),
          const SizedBox(height: 20),

          // BỎ FutureBuilder, gọi hàm trực tiếp
          QuestionCard(
            questionNumber: _currentQuestion + 1,
            mode: _modeNames[_selectedMode],
            targetVocab: _quizList[_currentQuestion],
            options: currentOptions,
            onCheckAnswer: () {},
            onAnswered: _handleAnswered,
          ),
          const SizedBox(height: 20),

          const QuizTipBox(),
        ],
      ),
    );
  }

  Widget _buildResultScreen(Color textPrimary, Color textSecondary) {
    final score = _quizList.isEmpty ? 0 : (_correctCount / _quizList.length * 100).round();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              score >= 70 ? Icons.celebration : Icons.trending_up,
              size: 80,
              color: score >= 70 ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 24),
            Text(
              'Hoàn thành bài kiểm tra!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              '$score%',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount đúng / $_wrongCount sai',
              style: TextStyle(fontSize: 16, color: textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFinished = false;
                  });
                  _generateQuiz();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Làm bài mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
