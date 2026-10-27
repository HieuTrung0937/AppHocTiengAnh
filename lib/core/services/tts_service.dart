import 'package:flutter_tts/flutter_tts.dart';

/// Dịch vụ quản lý phát âm Text-to-Speech
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Khởi tạo TTS
  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc vừa phải
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  /// Phát âm với giọng Anh-Mỹ
  Future<void> speakUS(String text) async {
    await init();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.speak(text);
  }

  /// Phát âm với giọng Anh-Anh
  Future<void> speakUK(String text) async {
    await init();
    await _flutterTts.setLanguage('en-GB');
    await _flutterTts.speak(text);
  }

  /// Dừng phát âm
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
