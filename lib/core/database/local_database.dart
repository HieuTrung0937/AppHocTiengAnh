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
      nextReviewDate: null,
      interval: 0,
      easeFactor: 2.5,
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

  /// Xóa 1 từ
  Future<bool> deleteVocabulary(String id) async {
    final initialLength = _vocabularies.length;
    _vocabularies.removeWhere((v) => v.id == id);
    if (_vocabularies.length < initialLength) {
      await _saveToDisk();
      return true;
    }
    return false;
  }

  /// ✅ MỚI: Xóa hàng loạt theo danh sách ID
  Future<int> deleteVocabularies(List<String> ids) async {
    final initialLength = _vocabularies.length;
    _vocabularies.removeWhere((v) => ids.contains(v.id));
    final deletedCount = initialLength - _vocabularies.length;
    if (deletedCount > 0) {
      await _saveToDisk();
    }
    return deletedCount;
  }

  bool existsInPersonal(String word) {
    return _vocabularies.any((v) => v.word.toLowerCase() == word.toLowerCase() && !v.isBuiltIn);
  }

  Future<List<VocabModel>> getWordsToReview({int limit = 20}) async {
    final userVocabs = _vocabularies.where((v) => !v.isBuiltIn).toList();
    userVocabs.sort((a, b) => b.calculatePriority().compareTo(a.calculatePriority()));
    return userVocabs.take(limit).toList();
  }

  Future<int> getDueReviewCount() async {
    final today = DateTime.now();
    return _vocabularies.where((v) {
      if (v.isBuiltIn) return false;
      if (v.nextReviewDate == null) return true;
      return v.nextReviewDate!.isBefore(today.add(const Duration(days: 1)));
    }).length;
  }

  List<VocabModel> _getSampleData() {
    return BuiltinDictionary.words.map((w) => VocabModel(
      id: w['id'] as String, word: w['word'] as String, phonetic: w['phonetic'] as String,
      meaning: w['meaning'] as String, partOfSpeech: w['partOfSpeech'] as String,
      example: w['example'] as String, source: 'Từ điển có sẵn', isBuiltIn: true,
      grade: w['grade'] as int?, difficulty: w['difficulty'] as int,
    )).toList();
  }
}
