import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final LocalDatabase _database = LocalDatabase();
  String _selectedGroup = 'Đã thêm';
  List<VocabModel> _vocabularies = [];
  bool _isLoading = false;

  final List<String> _groups = ['Đã thêm', 'Hay quên', 'Từ điển có sẵn'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _database.getVocabularyByGroup(_selectedGroup);
    if (mounted) {
      setState(() {
        _vocabularies = data;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(VocabModel vocab) {
    if (vocab.forgetCount >= 3) return AppColors.error;
    if (vocab.lastReviewDate == null) return AppColors.success;
    if (vocab.errorRate < 0.2 && vocab.forgetCount == 0) return AppColors.primary;
    return AppColors.warning;
  }

  String _getStatusText(VocabModel vocab) {
    if (vocab.forgetCount >= 3) return 'Hay quên';
    if (vocab.lastReviewDate == null) return 'Từ mới';
    if (vocab.errorRate < 0.2 && vocab.forgetCount == 0) return 'Đã thuộc';
    return 'Đang học';
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
        title: Text('Kho từ vựng', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 3 Tab chính
          Container(
            height: 50,
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _groups.map((group) {
                final isSelected = _selectedGroup == group;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGroup = group;
                        _loadData();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : cardBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          group,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Danh sách từ
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vocabularies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: textSecondary),
                            const SizedBox(height: 12),
                            Text('Chưa có từ vựng nào.', style: TextStyle(color: textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _vocabularies.length,
                        itemBuilder: (context, index) {
                          return _buildVocabCard(_vocabularies[index], cardBgColor, textPrimary, textSecondary);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedGroup == 'Đã thêm'
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildVocabCard(VocabModel vocab, Color cardColor, Color textPrimary, Color textSecondary) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(vocab.word, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(vocab).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(vocab),
                    style: TextStyle(color: _getStatusColor(vocab), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(vocab.phonetic, style: TextStyle(fontSize: 14, color: textSecondary)),
            const SizedBox(height: 8),
            Text(vocab.meaning, style: TextStyle(fontSize: 16, color: textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.book_outlined, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('Nguồn: ${vocab.source}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                const Spacer(),
                if (vocab.forgetCount > 0)
                  Text('${vocab.forgetCount} lần quên', style: const TextStyle(fontSize: 11, color: AppColors.error)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
