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

  // ✅ Chế độ chọn nhiều (Multi-select)
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};

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
        // Thoát chế độ chọn khi load dữ liệu mới
        if (_isSelectionMode) _exitSelectionMode();
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

  // ✅ Logic chế độ chọn nhiều
  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _exitSelectionMode();
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds = _filteredVocabularies.map((v) => v.id).toSet();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa các từ đã chọn?'),
        content: Text('Bạn có chắc muốn xóa ${_selectedIds.length} từ vựng? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final deletedCount = await _database.deleteVocabularies(_selectedIds.toList());
      _exitSelectionMode();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $deletedCount từ vựng')),
        );
      }
    }
  }

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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm từ vựng mới')));
            _loadData();
          }
        },
      ),
    );
  }

  void _openEditModal(VocabModel vocab) {
    _exitSelectionMode();
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật từ vựng')));
            _loadData();
          }
        },
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

    // Chỉ hiện nút "Chọn" ở tab "Đã thêm" và khi không tìm kiếm
    final canSelect = _selectedGroup == 'Đã thêm' && _searchController.text.isEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _isSelectionMode
            ? Text('Đã chọn ${_selectedIds.length}', style: TextStyle(color: textPrimary, fontSize: 18))
            : Text('Kho từ vựng', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        leading: _isSelectionMode
            ? IconButton(icon: Icon(Icons.close, color: textPrimary), onPressed: _exitSelectionMode)
            : null,
        actions: [
          if (_isSelectionMode)
            TextButton(
              onPressed: _selectedIds.length == _filteredVocabularies.length ? null : _selectAll,
              child: Text('Tất cả', style: TextStyle(color: AppColors.primary)),
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            ),
          if (! _isSelectionMode && canSelect)
            IconButton(
              icon: const Icon(Icons.checklist, color: AppColors.primary),
              onPressed: () {
                // Không làm gì, chỉ để người dùng biết có thể long-press
              },
            ),
        ],
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
                          final isSelected = _selectedIds.contains(vocab.id);
                          
                          // Vuốt để xóa nhanh (chỉ khi không ở chế độ chọn)
                          if (_selectedGroup == 'Đã thêm' && !_isSelectionMode) {
                            return Dismissible(
                              key: Key(vocab.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
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
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa từ vựng')));
                                  _loadData();
                                }
                              },
                              child: _buildVocabCard(vocab, cardBgColor, textPrimary, textSecondary, isSelected: false),
                            );
                          }
                          return _buildVocabCard(vocab, cardBgColor, textPrimary, textSecondary, isSelected: isSelected);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedGroup == 'Đã thêm' && _searchController.text.isEmpty && !_isSelectionMode
          ? FloatingActionButton(
              onPressed: _openAddModal,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildVocabCard(VocabModel vocab, Color cardColor, Color textPrimary, Color textSecondary, {required bool isSelected}) {
    return InkWell(
      // Nếu đang ở chế độ chọn: chạm để tích/bỏ tích
      // Nếu không: chạm để xem chi tiết
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(vocab.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VocabDetailScreen(vocab: vocab, isBuiltIn: vocab.isBuiltIn)),
          );
        }
      },
      // Giữ lâu để vào chế độ chọn (chỉ ở tab "Đã thêm")
      onLongPress: () {
        if (_selectedGroup == 'Đã thêm' && !_isSelectionMode) {
          _enterSelectionMode(vocab.id);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.5),
        ),
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox khi ở chế độ chọn
              if (_isSelectionMode) ...[
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}
