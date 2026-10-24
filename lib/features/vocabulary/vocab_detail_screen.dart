import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/services/tts_service.dart';

class VocabDetailScreen extends StatefulWidget {
  final VocabModel vocab;
  final bool isBuiltIn; // Để xác định có hiện nút "Thêm vào từ điển" hay không

  const VocabDetailScreen({
    super.key, 
    required this.vocab, 
    required this.isBuiltIn,
  });

  @override
  State<VocabDetailScreen> createState() => _VocabDetailScreenState();
}

class _VocabDetailScreenState extends State<VocabDetailScreen> {
  final TtsService _ttsService = TtsService();
  final LocalDatabase _database = LocalDatabase();
  bool _isAdded = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem từ này đã được thêm vào từ điển cá nhân chưa
    if (widget.isBuiltIn) {
      _checkIfAdded();
    }
  }

  Future<void> _checkIfAdded() async {
    final allVocabs = await _database.getAllVocabulary();
    final exists = allVocabs.any((v) => v.word == widget.vocab.word && !v.isBuiltIn);
    if (mounted) {
      setState(() => _isAdded = exists);
    }
  }

  Future<void> _addToPersonal() async {
    if (_isAdded) return;
    setState(() => _isAdding = true);
    
    final success = await _database.addToPersonalDictionary(widget.vocab);
    
    if (mounted) {
      setState(() {
        _isAdding = false;
        _isAdded = success;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào từ điển của tôi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final cardBgColor = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final textSecondary = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần từ vựng và phát âm
            Card(
              color: cardBgColor,
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vocab.word,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.vocab.partOfSpeech,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.vocab.phonetic,
                      style: TextStyle(fontSize: 16, color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                    // Nút phát âm
                    Row(
                      children: [
                        _buildAudioButton(
                          icon: Icons.volume_up,
                          label: 'Anh Mỹ',
                          onTap: () => _ttsService.speakUS(widget.vocab.word),
                        ),
                        const SizedBox(width: 12),
                        _buildAudioButton(
                          icon: Icons.volume_up,
                          label: 'Anh Anh',
                          onTap: () => _ttsService.speakUK(widget.vocab.word),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Phần nghĩa
            if (widget.vocab.meaning.isNotEmpty) ...[
              _buildSectionTitle('Nghĩa', textPrimary),
              const SizedBox(height: 8),
              Card(
                color: cardBgColor,
                surfaceTintColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.vocab.meaning,
                    style: TextStyle(fontSize: 16, color: textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. Phần ví dụ và ngữ cảnh
            if (widget.vocab.example.isNotEmpty) ...[
              _buildSectionTitle('Ví dụ', textPrimary),
              const SizedBox(height: 8),
              Card(
                color: cardBgColor,
                surfaceTintColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vocab.example,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Nút thêm vào từ điển cá nhân (Chỉ hiện nếu là từ điển có sẵn)
            if (widget.isBuiltIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAdded || _isAdding ? null : _addToPersonal,
                  icon: _isAdding 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(_isAdded ? Icons.check : Icons.add),
                  label: Text(_isAdded ? 'Đã thêm vào từ điển của tôi' : 'Thêm vào từ điển của tôi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAdded ? AppColors.success : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
