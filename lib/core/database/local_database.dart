import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'vocab_model.dart';
import 'builtin_dictionary.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  List<VocabModel> _vocabularies = [];
  static const String _storageKey = 'memora_vocab_data';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);

    if (savedData != null) {
      final List<dynamic> decoded = json.decode(savedData);
      _vocabularies = decoded.map((e) => VocabModel.fromJson(e)).toList();
    } else {
      _vocabularies = _getSampleData();
      await _saveToDisk();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_vocabularies.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<VocabModel>> getAllVocabulary() async => List.from(_vocabularies);

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

  Future<List<VocabModel>> getVocabularyByGrade(int? grade) async {
    if (grade == null) return getAllVocabulary();
    return _vocabularies.where((v) => v.grade == grade).toList();
  }

  Future<void> addVocabulary(VocabModel vocab) async {
    _vocabularies.add(vocab);
    await _saveToDisk();
  }

  Future<bool> addToPersonalDictionary(VocabModel vocab) async {
    final exists = _vocabularies.any((v) => v.word.toLowerCase() == vocab.word.toLowerCase() && !v.isBuiltIn);
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
    await _saveToDisk();
    return true;
  }

  Future<void> updateVocabulary(VocabModel vocab) async {
    final index = _vocabularies.indexWhere((v) => v.id == vocab.id);
    if (index != -1) {
      _vocabularies[index] = vocab;
      await _saveToDisk();
    }
  }

  /// ✅ MỚI: Xóa từ vựng
  Future<bool> deleteVocabulary(String id) async {
    final initialLength = _vocabularies.length;
    _vocabularies.removeWhere((v) => v.id == id);
    if (_vocabularies.length < initialLength) {
      await _saveToDisk();
      return true;
    }
    return false;
  }

  /// ✅ MỚI: Kiểm tra từ đã tồn tại trong "Đã thêm" chưa
  bool existsInPersonal(String word) {
    return _vocabularies.any((v) => v.word.toLowerCase() == word.toLowerCase() && !v.isBuiltIn);
  }

  Future<List<VocabModel>> getWordsToReview({int limit = 20}) async {
    final sorted = List<VocabModel>.from(_vocabularies);
    sorted.sort((a, b) => b.calculatePriority().compareTo(a.calculatePriority()));
    return sorted.take(limit).toList();
  }

  List<VocabModel> _getSampleData() {
    final builtinWords = BuiltinDictionary.words.map((w) => VocabModel(
      id: w['id'] as String, word: w['word'] as String, phonetic: w['phonetic'] as String,
      meaning: w['meaning'] as String, partOfSpeech: w['partOfSpeech'] as String,
      example: w['example'] as String, source: 'Từ điển có sẵn', isBuiltIn: true,
      grade: w['grade'] as int?, difficulty: w['difficulty'] as int,
    )).toList();

    final userWords = [
      VocabModel(
        id: 'user_001', word: 'environment', phonetic: '/ɪnˈvaɪ.rən.mənt/', meaning: 'môi trường',
        partOfSpeech: 'danh từ', example: 'We need to protect the environment.',
        source: 'Quét OCR', isBuiltIn: false, grade: 10, difficulty: 3, forgetCount: 4, errorRate: 0.8,
        lastReviewDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VocabModel(
        id: 'user_002', word: 'recycle', phonetic: '/riːˈsaɪ.kəl/', meaning: 'tái chế',
        partOfSpeech: 'động từ', example: 'We recycle plastic bottles.',
        source: 'Nhập tay', isBuiltIn: false, grade: 10, difficulty: 2, forgetCount: 3, errorRate: 0.6,
        lastReviewDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    return [...builtinWords, ...userWords];
  }
}
