import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/local_database.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/features/vocabulary/vocab_detail_screen.dart';
import 'package:app_hoc_tieng_anh/features/vocabulary/components/add_edit_vocab_modal.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final LocalDatabase _database = LocalDatabase();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _selectedGroup = 'Đã thêm';
  int? _selectedGrade;
  List<VocabModel> _vocabularies = [];
  List<VocabModel> _filteredVocabularies = [];
  bool _isLoading = false;

  final List<String> _groups = ['Đã thêm', 'Hay quên', 'Từ điển có sẵn'];
  final List<int?> _grades = [null, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() => _applyFilters();

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<VocabModel> data;
    
    if (_selectedGrade == null) {
      data = await _database.getVocabularyByGroup(_selectedGroup);
    } else {
      final all = await _database.getAllVocabulary();
      data = all.where((v) {
        bool matchGrade = v.grade == _selectedGrade;
        bool matchGroup = true;
        if (_selectedGroup == 'Đã thêm') matchGroup = !v.isBuiltIn;
        else if (_selectedGroup == 'Hay quên') matchGroup = v.forgetCount >= 3;
        else if (_selectedGroup == 'Từ điển có sẵn') matchGroup = v.isBuiltIn;
        return matchGrade && matchGroup;
      }).toList();
    }

    if (mounted) {
      setState(() {
        _vocabularies = data;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    String keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      _filteredVocabularies = _vocabularies;
    } else {
      _filteredVocabularies = _vocabularies.where((vocab) {
        return vocab.word.toLowerCase().contains(keyword) ||
               vocab.meaning.toLowerCase().contains(keyword);
      }).toList();
    }
    if (mounted) setState(() {});
  }

  void _changeGroup(String group) {
    setState(() {
      _selectedGroup = group;
      _selectedGrade = null;
      _searchController.clear();
      _loadData();
    });
  }

  void _changeGrade(int? grade) {
    setState(() {
      _selectedGrade = grade;
      _loadData();
    });
  }

  /// ✅ THÊM: Mở modal thêm từ mới
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditVocabModal(
        onSave: (vocab) async {
          await _database.addVocabulary(vocab);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm từ vựng mới')),
            );
            _loadData();
          }
        },
      ),
    );
  }

  /// ✅ SỬA: Mở modal chỉnh sửa
  void _openEditModal(VocabModel vocab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditVocabModal(
        vocab: vocab,
        onSave: (updatedVocab) async {
          await _database.updateVocabulary(updatedVocab);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật từ vựng')),
            );
            _loadData();
          }
        },
      ),
    );
  }

  /// ✅ XÓA: Hiển thị dialog xác nhận
  void _confirmDelete(VocabModel vocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa từ vựng?'),
        content: Text('Bạn có chắc muốn xóa "${vocab.word}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _database.deleteVocabulary(vocab.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa từ vựng')),
                );
                _loadData();
              }
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
    final inputBgColor = theme.colorScheme.surfaceContainerHighest ?? AppColors.surfaceVariant;

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
          Container(
            height: 50,
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _groups.map((group) {
                final isSelected = _selectedGroup == group;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _changeGroup(group),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : cardBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(group, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : textSecondary)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_selectedGroup != 'Hay quên')
            Container(
              height: 40,
              color: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _grades.length,
                itemBuilder: (context, index) {
                  final grade = _grades[index];
                  final isSelected = _selectedGrade == grade;
                  final label = grade == null ? 'Tất cả' : 'Lớp $grade';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : textSecondary)),
                      backgroundColor: isSelected ? AppColors.primary.withOpacity(0.8) : cardBgColor,
                      side: BorderSide(color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant.withOpacity(0.3)),
                      onPressed: () => _changeGrade(grade),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm từ vựng, nghĩa...',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: Icon(Icons.clear, color: textSecondary, size: 20), onPressed: () { _searchController.clear(); _searchFocusNode.unfocus(); })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: textPrimary, fontSize: 14),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [Text('Tìm thấy ${_filteredVocabularies.length} kết quả', style: TextStyle(fontSize: 12, color: textSecondary))]),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVocabularies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: textSecondary),
                            const SizedBox(height: 12),
                            Text(_searchController.text.isNotEmpty ? 'Không tìm thấy từ phù hợp.' : 'Chưa có từ vựng nào.', style: TextStyle(color: textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredVocabularies.length,
                        itemBuilder: (context, index) {
                          final vocab = _filteredVocabularies[index];
                          // ✅ Swipe to delete chỉ hiện ở tab "Đã thêm"
                          if (_selectedGroup == 'Đã thêm') {
                            return Dismissible(
                              key: Key(vocab.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xóa từ vựng?'),
                                    content: Text('Bạn có chắc muốn xóa "${vocab.word}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: AppColors.error))),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) async {
                                await _database.deleteVocabulary(vocab.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã xóa từ vựng')),
                                  );
                                  _loadData();
                                }
                              },
                              child: _buildVocabCard(vocab, cardBgColor, textPrimary, textSecondary),
                            );
                          }
                          return _buildVocabCard(vocab, cardBgColor, textPrimary, textSecondary);
                        },
                      ),
          ),
        ],
      ),
      // ✅ FAB chỉ hiện ở tab "Đã thêm" khi không search
      floatingActionButton: _selectedGroup == 'Đã thêm' && _searchController.text.isEmpty
          ? FloatingActionButton(
              onPressed: _openAddModal,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildVocabCard(VocabModel vocab, Color cardColor, Color textPrimary, Color textSecondary) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VocabDetailScreen(vocab: vocab, isBuiltIn: vocab.isBuiltIn)),
        );
      },
      onLongPress: () {
        // ✅ Long press để hiện menu (chỉ ở tab "Đã thêm")
        if (_selectedGroup == 'Đã thêm') {
          _showVocabMenu(vocab);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
                  Row(
                    children: [
                      if (vocab.grade != null)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text('L${vocab.grade}', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _getStatusColor(vocab).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(_getStatusText(vocab), style: TextStyle(color: _getStatusColor(vocab), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
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
                  if (vocab.forgetCount > 0) Text('${vocab.forgetCount} lần quên', style: const TextStyle(fontSize: 11, color: AppColors.error)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Menu popup khi long-press (chỉ ở tab "Đã thêm")
  void _showVocabMenu(VocabModel vocab) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                _openEditModal(vocab);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Xóa', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(vocab);
              },
            ),
          ],
        ),
      ),
    );
  }
}
