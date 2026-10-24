import 'vocab_model.dart';
import 'builtin_dictionary.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  List<VocabModel> _vocabularies = [];

  Future<void> init() async {
    _vocabularies = _getSampleData();
  }

  Future<List<VocabModel>> getAllVocabulary() async {
    return List.from(_vocabularies);
  }

  Future<List<VocabModel>> getVocabularyByGroup(String group) async {
    switch (group) {
      case 'Đã thêm':
        return _vocabularies.where((v) => !v.isBuiltIn).toList();
      case 'Hay quên':
        return _vocabularies.where((v) => v.forgetCount >= 3).toList();
      case 'Từ điển có sẵn':
        return _vocabularies.where((v) => v.isBuiltIn).toList();
      default:
        return getAllVocabulary();
    }
  }

  /// Lọc thêm theo Lớp (Grade)
  Future<List<VocabModel>> getVocabularyByGrade(int? grade) async {
    if (grade == null) return getAllVocabulary();
    return _vocabularies.where((v) => v.grade == grade).toList();
  }

  Future<void> addVocabulary(VocabModel vocab) async {
    _vocabularies.add(vocab);
  }

  Future<bool> addToPersonalDictionary(VocabModel vocab) async {
    final exists = _vocabularies.any((v) => v.word == vocab.word && !v.isBuiltIn);
    if (exists) return false;

    final personalVocab = vocab.copyWith(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      isBuiltIn: false,
      source: 'Từ điển có sẵn',
      forgetCount: 0,
      errorRate: 0.0,
      lastReviewDate: null,
    );
    
    _vocabularies.add(personalVocab);
    return true;
  }

  Future<void> updateVocabulary(VocabModel vocab) async {
    final index = _vocabularies.indexWhere((v) => v.id == vocab.id);
    if (index != -1) {
      _vocabularies[index] = vocab;
    }
  }

  Future<List<VocabModel>> getWordsToReview({int limit = 20}) async {
    final sorted = List<VocabModel>.from(_vocabularies);
    sorted.sort((a, b) => b.calculatePriority().compareTo(a.calculatePriority()));
    return sorted.take(limit).toList();
  }

  List<VocabModel> _getSampleData() {
    final builtinWords = BuiltinDictionary.words.map((w) => VocabModel(
      id: w['id'] as String,
      word: w['word'] as String,
      phonetic: w['phonetic'] as String,
      meaning: w['meaning'] as String,
      partOfSpeech: w['partOfSpeech'] as String,
      example: w['example'] as String,
      source: 'Từ điển có sẵn',
      isBuiltIn: true,
      grade: w['grade'] as int?, // Gán grade từ dictionary
      difficulty: w['difficulty'] as int,
    )).toList();

    final userWords = [
      VocabModel(
        id: 'user_001', word: 'pollution', phonetic: '/pəˈluː.ʃən/', meaning: 'ô nhiễm',
        partOfSpeech: 'danh từ', example: 'Air pollution is bad.',
        source: 'Quét OCR', isBuiltIn: false, grade: 10, difficulty: 2, forgetCount: 4, errorRate: 0.8,
        lastReviewDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return [...builtinWords, ...userWords];
  }
}
