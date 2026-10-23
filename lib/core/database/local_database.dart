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

  /// Lọc theo 3 nhóm chính
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

  Future<void> addVocabulary(VocabModel vocab) async {
    _vocabularies.add(vocab);
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

  /// Tạo danh sách từ mẫu + từ điển cứng
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
      difficulty: w['difficulty'] as int,
    )).toList();

    // Từ do người dùng thêm (mẫu test)
    final userWords = [
      VocabModel(
        id: 'user_001', word: 'environment', phonetic: '/ɪnvaɪ.rən.mənt/', meaning: 'môi trường',
        partOfSpeech: 'danh từ', example: 'We need to protect the environment.',
        source: 'Quét OCR', isBuiltIn: false, difficulty: 3, forgetCount: 4, errorRate: 0.7,
        lastReviewDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VocabModel(
        id: 'user_002', word: 'recycle', phonetic: '/riːˈsaɪ.kəl/', meaning: 'tái chế',
        partOfSpeech: 'động từ', example: 'We recycle plastic bottles.',
        source: 'Nhập tay', isBuiltIn: false, difficulty: 2, forgetCount: 3, errorRate: 0.6,
        lastReviewDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    return [...builtinWords, ...userWords];
  }
}
