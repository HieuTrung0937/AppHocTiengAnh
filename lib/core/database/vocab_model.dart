import 'package:app_hoc_tieng_anh/core/constants/app_constants.dart';

class VocabModel {
  final String id;
  final String word;
  final String phonetic;
  final String meaning;
  final String partOfSpeech;
  final String example;
  final String context;
  final String source;
  final bool isBuiltIn;
  
  // Trường mới: Phân loại theo lớp (10, 11, 12 hoặc null cho từ tự thêm)
  final int? grade; 
  
  final int difficulty;
  final int forgetCount;
  final double errorRate;
  final DateTime? lastReviewDate;
  final DateTime createdAt;
  final bool isFavorite;

  VocabModel({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.meaning,
    this.partOfSpeech = '',
    required this.example,
    this.context = '',
    this.source = 'Nhập tay',
    this.isBuiltIn = false,
    this.grade, // Mặc định null
    this.difficulty = 3,
    this.forgetCount = 0,
    this.errorRate = 0.0,
    this.lastReviewDate,
    DateTime? createdAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String get dynamicStatus {
    if (forgetCount >= 3) return 'Hay quên';
    if (lastReviewDate == null) return 'Từ mới';
    if (errorRate < 0.2 && forgetCount == 0) return 'Đã thuộc';
    return 'Đang học';
  }

  String get gradeLabel {
    if (grade == null) return '';
    return 'Lớp $grade';
  }

  double calculatePriority() {
    double timeFactor = 0;
    if (lastReviewDate != null) {
      final days = DateTime.now().difference(lastReviewDate!).inDays.toDouble();
      timeFactor = (days / 30).clamp(0.0, 1.0);
    } else {
      timeFactor = 1.0;
    }
    final normalizedErrorRate = errorRate.clamp(0.0, 1.0);
    final normalizedDifficulty = (difficulty / 5).clamp(0.0, 1.0);
    return (AppConstants.weightTime * timeFactor) +
           (AppConstants.weightErrorRate * normalizedErrorRate) +
           (AppConstants.weightDifficulty * normalizedDifficulty);
  }

  VocabModel updateAfterReview(int quality) {
    final bool isCorrect = quality >= 2;
    final newErrorRate = isCorrect ? (errorRate * 0.7) : (errorRate * 0.3 + 0.7);
    final newForgetCount = isCorrect ? forgetCount : forgetCount + 1;
    return copyWith(
      lastReviewDate: DateTime.now(),
      errorRate: newErrorRate.clamp(0.0, 1.0),
      forgetCount: newForgetCount,
    );
  }

  VocabModel copyWith({
    String? id, String? word, String? phonetic, String? meaning,
    String? partOfSpeech, String? example, String? context, String? source,
    bool? isBuiltIn, int? grade, int? difficulty, int? forgetCount, double? errorRate,
    DateTime? lastReviewDate, DateTime? createdAt, bool? isFavorite,
  }) {
    return VocabModel(
      id: id ?? this.id, word: word ?? this.word, phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning, partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      example: example ?? this.example, context: context ?? this.context,
      source: source ?? this.source, isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      grade: grade ?? this.grade, difficulty: difficulty ?? this.difficulty,
      forgetCount: forgetCount ?? this.forgetCount, errorRate: errorRate ?? this.errorRate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      createdAt: createdAt ?? this.createdAt, isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
