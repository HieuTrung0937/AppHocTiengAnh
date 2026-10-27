import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';

/// Modal thêm/sửa từ vựng
class AddEditVocabModal extends StatefulWidget {
  final VocabModel? vocab; // null = thêm mới, có giá trị = chỉnh sửa
  final Function(VocabModel) onSave;

  const AddEditVocabModal({
    super.key,
    this.vocab,
    required this.onSave,
  });

  @override
  State<AddEditVocabModal> createState() => _AddEditVocabModalState();
}

class _AddEditVocabModalState extends State<AddEditVocabModal> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _phoneticController = TextEditingController();
  final _meaningController = TextEditingController();
  final _partOfSpeechController = TextEditingController();
  final _exampleController = TextEditingController();
  final _contextController = TextEditingController();
  
  int? _selectedGrade;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.vocab != null) {
      _wordController.text = widget.vocab!.word;
      _phoneticController.text = widget.vocab!.phonetic;
      _meaningController.text = widget.vocab!.meaning;
      _partOfSpeechController.text = widget.vocab!.partOfSpeech;
      _exampleController.text = widget.vocab!.example;
      _contextController.text = widget.vocab!.context;
      _selectedGrade = widget.vocab!.grade;
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _phoneticController.dispose();
    _meaningController.dispose();
    _partOfSpeechController.dispose();
    _exampleController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final isEdit = widget.vocab != null;
    final vocab = VocabModel(
      id: isEdit ? widget.vocab!.id : 'user_${DateTime.now().millisecondsSinceEpoch}',
      word: _wordController.text.trim(),
      phonetic: _phoneticController.text.trim(),
      meaning: _meaningController.text.trim(),
      partOfSpeech: _partOfSpeechController.text.trim(),
      example: _exampleController.text.trim(),
      context: _contextController.text.trim(),
      source: isEdit ? widget.vocab!.source : 'Nhập tay',
      isBuiltIn: false,
      grade: _selectedGrade,
      difficulty: widget.vocab?.difficulty ?? 3,
      forgetCount: widget.vocab?.forgetCount ?? 0,
      errorRate: widget.vocab?.errorRate ?? 0.0,
      lastReviewDate: widget.vocab?.lastReviewDate,
      createdAt: widget.vocab?.createdAt ?? DateTime.now(),
    );

    // Delay nhỏ để UX mượt hơn
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSaving = false);
        widget.onSave(vocab);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final inputBgColor = theme.colorScheme.surfaceContainerHighest ?? AppColors.surfaceVariant;
    final isEdit = widget.vocab != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3))),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textSecondary),
                ),
                Expanded(
                  child: Text(
                    isEdit ? 'Chỉnh sửa từ vựng' : 'Thêm từ vựng mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                ),
                TextButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          'Lưu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Từ vựng (bắt buộc)
                    _buildTextField(
                      controller: _wordController,
                      label: 'Từ vựng *',
                      hint: 'Ví dụ: environment',
                      icon: Icons.text_fields,
                      textCapitalization: TextCapitalization.none,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập từ vựng' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phiên âm
                    _buildTextField(
                      controller: _phoneticController,
                      label: 'Phiên âm',
                      hint: 'Ví dụ: /ɪnˈvaɪ.rən.mənt/',
                      icon: Icons.record_voice_over,
                    ),
                    const SizedBox(height: 16),

                    // Loại từ
                    _buildTextField(
                      controller: _partOfSpeechController,
                      label: 'Loại từ',
                      hint: 'Ví dụ: danh từ, động từ, tính từ...',
                      icon: Icons.category,
                    ),
                    const SizedBox(height: 16),

                    // Nghĩa (bắt buộc)
                    _buildTextField(
                      controller: _meaningController,
                      label: 'Nghĩa (tiếng Việt) *',
                      hint: 'Ví dụ: môi trường',
                      icon: Icons.translate,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nghĩa' : null,
                    ),
                    const SizedBox(height: 16),

                    // Ví dụ
                    _buildTextField(
                      controller: _exampleController,
                      label: 'Ví dụ',
                      hint: 'We need to protect the environment.',
                      icon: Icons.format_quote,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Ngữ cảnh
                    _buildTextField(
                      controller: _contextController,
                      label: 'Ngữ cảnh / Ghi chú',
                      hint: 'Từ này thường xuất hiện trong chủ đề môi trường...',
                      icon: Icons.note_alt,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Chọn lớp
                    Text(
                      'Lớp',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedGrade,
                          isExpanded: true,
                          hint: Text('Chọn lớp (tùy chọn)', style: TextStyle(color: textSecondary)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Không phân lớp')),
                            const DropdownMenuItem(value: 10, child: Text('Lớp 10')),
                            const DropdownMenuItem(value: 11, child: Text('Lớp 11')),
                            const DropdownMenuItem(value: 12, child: Text('Lớp 12')),
                          ],
                          onChanged: (value) => setState(() => _selectedGrade = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final inputBgColor = theme.colorScheme.surfaceContainerHighest ?? AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(color: textPrimary, fontSize: 15),
          validator: validator,
        ),
      ],
    );
  }
}
