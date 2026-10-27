import 'dart:convert';
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
  final int? grade;
  
  final int difficulty;
  final int forgetCount;
  final double errorRate;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate; // ✅ Ngày cần ôn tiếp theo (Spaced Repetition)
  final int interval; // ✅ Số ngày giữa các lần ôn (SM-2 algorithm)
  final double easeFactor; // ✅ Hệ số dễ (SM-2 algorithm)
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
    this.grade,
    this.difficulty = 3,
    this.forgetCount = 0,
    this.errorRate = 0.0,
    this.lastReviewDate,
    this.nextReviewDate,
    this.interval = 0,
    this.easeFactor = 2.5,
    DateTime? createdAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String get dynamicStatus {
    if (forgetCount >= 3) return 'Hay quên';
    if (lastReviewDate == null) return 'Từ mới';
    if (errorRate < 0.2 && forgetCount == 0) return 'Đã thuộc';
    return 'Đang học';
  }

  String get gradeLabel => grade != null ? 'Lớp $grade' : '';

  /// ✅ THUẬT TOÁN SPACED REPETITION (SM-2 đơn giản)
  /// Tính ngày ôn tiếp theo dựa trên quality và interval hiện tại
  VocabModel updateAfterReview(int quality) {
    // quality: 0=Chưa nhớ, 1=Nhớ một phần, 2=Đã nhớ, 3=Nhớ tốt
    
    int newInterval;
    double newEaseFactor = easeFactor;
    final newForgetCount = quality >= 2 ? forgetCount : forgetCount + 1;
    
    // Tính errorRate mới
    final bool isCorrect = quality >= 2;
    final newErrorRate = isCorrect ? (errorRate * 0.7) : (errorRate * 0.3 + 0.7);
    
    if (quality == 0) {
      // Quên hoàn toàn: reset về ngày mai
      newInterval = 1;
      newEaseFactor = easeFactor.clamp(1.3, 2.5);
    } else if (quality == 1) {
      // Nhớ một phần: interval ngắn
      newInterval = interval == 0 ? 2 : (interval * 1.2).round();
      newEaseFactor = (easeFactor - 0.2).clamp(1.3, 2.5);
    } else if (quality == 2) {
      // Đã nhớ: interval tăng theo ease factor
      newInterval = interval == 0 ? 4 : (interval * easeFactor).round();
    } else {
      // Nhớ tốt: interval tăng mạnh
      newInterval = interval == 0 ? 7 : (interval * easeFactor * 1.3).round();
      newEaseFactor = (easeFactor + 0.1).clamp(1.3, 2.5);
    }
    
    // Giới hạn interval tối đa 365 ngày
    newInterval = newInterval.clamp(1, 365);
    
    final newNextReviewDate = DateTime.now().add(Duration(days: newInterval));
    
    return copyWith(
      lastReviewDate: DateTime.now(),
      nextReviewDate: newNextReviewDate,
      interval: newInterval,
      easeFactor: newEaseFactor,
      errorRate: newErrorRate.clamp(0.0, 1.0),
      forgetCount: newForgetCount,
    );
  }

  /// ✅ PRIORITY: Ưu tiên từ cần ôn hôm nay hoặc quá hạn
  double calculatePriority() {
    // Nếu chưa ever review, ưu tiên cao
    if (lastReviewDate == null) {
      return 1.0;
    }
    
    // Nếu đã đến ngày ôn (nextReviewDate <= hôm nay), ưu tiên cao
    if (nextReviewDate != null && nextReviewDate!.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      final daysOverdue = DateTime.now().difference(nextReviewDate!).inDays.toDouble();
      return 0.9 + (daysOverdue / 30).clamp(0.0, 0.1); // 0.9 - 1.0
    }
    
    // Nếu chưa đến ngày ôn, ưu tiên thấp hơn
    if (nextReviewDate != null) {
      final daysUntilReview = nextReviewDate!.difference(DateTime.now()).inDays.toDouble();
      return 0.5 - (daysUntilReview / 30).clamp(0.0, 0.5); // 0.0 - 0.5
    }
    
    // Fallback: dựa vào errorRate và difficulty
    final normalizedErrorRate = errorRate.clamp(0.0, 1.0);
    final normalizedDifficulty = (difficulty / 5).clamp(0.0, 1.0);
    return (AppConstants.weightErrorRate * normalizedErrorRate) +
           (AppConstants.weightDifficulty * normalizedDifficulty);
  }

  VocabModel copyWith({
    String? id, String? word, String? phonetic, String? meaning,
    String? partOfSpeech, String? example, String? context, String? source,
    bool? isBuiltIn, int? grade, int? difficulty, int? forgetCount, double? errorRate,
    DateTime? lastReviewDate, DateTime? nextReviewDate, int? interval, double? easeFactor,
    DateTime? createdAt, bool? isFavorite,
  }) {
    return VocabModel(
      id: id ?? this.id, word: word ?? this.word, phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning, partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      example: example ?? this.example, context: context ?? this.context,
      source: source ?? this.source, isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      grade: grade ?? this.grade, difficulty: difficulty ?? this.difficulty,
      forgetCount: forgetCount ?? this.forgetCount, errorRate: errorRate ?? this.errorRate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      createdAt: createdAt ?? this.createdAt, isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'word': word, 'phonetic': phonetic, 'meaning': meaning,
      'partOfSpeech': partOfSpeech, 'example': example, 'context': context,
      'source': source, 'isBuiltIn': isBuiltIn, 'grade': grade,
      'difficulty': difficulty, 'forgetCount': forgetCount, 'errorRate': errorRate,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'interval': interval, 'easeFactor': easeFactor,
      'createdAt': createdAt.toIso8601String(), 'isFavorite': isFavorite,
    };
  }

  factory VocabModel.fromJson(Map<String, dynamic> json) {
    return VocabModel(
      id: json['id'], word: json['word'], phonetic: json['phonetic'] ?? '',
      meaning: json['meaning'], partOfSpeech: json['partOfSpeech'] ?? '',
      example: json['example'] ?? '', context: json['context'] ?? '',
      source: json['source'] ?? 'Nhập tay', isBuiltIn: json['isBuiltIn'] ?? false,
      grade: json['grade'], difficulty: json['difficulty'] ?? 3,
      forgetCount: json['forgetCount'] ?? 0, errorRate: (json['errorRate'] ?? 0.0).toDouble(),
      lastReviewDate: json['lastReviewDate'] != null ? DateTime.parse(json['lastReviewDate']) : null,
      nextReviewDate: json['nextReviewDate'] != null ? DateTime.parse(json['nextReviewDate']) : null,
      interval: json['interval'] ?? 0,
      easeFactor: (json['easeFactor'] ?? 2.5).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
