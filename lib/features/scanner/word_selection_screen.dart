import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';

class WordSelectionScreen extends StatefulWidget {
  final String recognizedText;
  final String imagePath;

  const WordSelectionScreen({super.key, required this.recognizedText, required this.imagePath});

  @override
  State<WordSelectionScreen> createState() => _WordSelectionScreenState();
}

class _WordSelectionScreenState extends State<WordSelectionScreen> {
  final LocalDatabase _database = LocalDatabase();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(); // Đổi tên để tránh trùng
  
  List<String> _extractedWords = [];
  Set<String> _selectedWords = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractWords();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _extractWords() {
    final words = widget.recognizedText
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r"[^a-zA-Z\-']"), ''))
        .where((w) => w.isNotEmpty && w.length > 2)
        .toSet()
        .toList();
    
    setState(() {
      _extractedWords = words;
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedWords() async {
    if (_selectedWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất 1 từ')));
      return;
    }

    final meaning = _meaningController.text.trim();
    final noteText = _noteController.text.trim(); // SỬA LỖI TRÙNG TÊN BIẾN

    for (String word in _selectedWords) {
      final vocab = VocabModel(
        id: 'ocr_${DateTime.now().millisecondsSinceEpoch}_$word',
        word: word.toLowerCase(),
        phonetic: '', 
        meaning: meaning, 
        example: noteText, 
        context: noteText,
        source: 'Quét OCR',
        isBuiltIn: false,
        difficulty: 3,
      );
      await _database.addVocabulary(vocab);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu thành công ${_selectedWords.length} từ vựng')));
      Navigator.pop(context);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedWords.length == _extractedWords.length) {
        _selectedWords.clear();
      } else {
        _selectedWords = _extractedWords.toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final cardBgColor = theme.cardColor;
    final inputBgColor = theme.colorScheme.surfaceContainerHighest ?? AppColors.surfaceVariant;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Chọn từ vựng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _selectedWords.isEmpty ? null : _saveSelectedWords,
            child: Text('Lưu (${_selectedWords.length})', style: TextStyle(color: _selectedWords.isEmpty ? AppColors.textHint : AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: inputBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Văn bản nhận diện:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(widget.recognizedText, style: TextStyle(fontSize: 14, color: textPrimary, height: 1.5), softWrap: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _meaningController,
                    decoration: InputDecoration(
                      labelText: 'Nghĩa (tiếng Việt) *',
                      hintText: 'Ví dụ: môi trường, trách nhiệm...',
                      prefixIcon: Icon(Icons.translate, color: AppColors.primary, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Ví dụ hoặc Ngữ cảnh (tùy chọn)',
                      hintText: 'Ví dụ: We must protect the environment.',
                      prefixIcon: Icon(Icons.note_alt_outlined, color: textSecondary, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Các từ trích xuất (${_extractedWords.length})', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                      TextButton(
                        onPressed: _extractedWords.isEmpty ? null : _toggleSelectAll,
                        child: Text(_selectedWords.length == _extractedWords.length ? 'Bỏ chọn tất cả' : 'Chọn tất cả', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _extractedWords.length,
                    itemBuilder: (context, index) {
                      final word = _extractedWords[index];
                      final isSelected = _selectedWords.contains(word);
                      
                      return Card(
                        color: isSelected ? AppColors.primary.withOpacity(0.08) : cardBgColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant.withOpacity(0.3), width: isSelected ? 1.5 : 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppColors.primary : textSecondary, size: 22),
                          title: Text(word, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: textPrimary)),
                          onTap: () {
                            setState(() {
                              isSelected ? _selectedWords.remove(word) : _selectedWords.add(word);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
