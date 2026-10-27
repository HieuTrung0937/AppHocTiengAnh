import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/theme_controller.dart';
import 'package:app_hoc_tieng_anh/core/controllers/user_controller.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeController themeController;
  final UserController userController;

  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.userController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userController.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn')),
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.userController.setUserName(newName);
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật tên')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final cardBgColor = theme.cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Tài khoản
            _buildSectionTitle('Tài khoản', textPrimary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.userController.userName.isNotEmpty 
                                ? widget.userController.userName[0].toUpperCase() 
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tên của bạn',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                            const SizedBox(height: 4),
                            if (_isEditingName)
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: 'Nhập tên...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onSubmitted: (_) => _saveName(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_isSaving)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    IconButton(
                                      onPressed: _saveName,
                                      icon: const Icon(Icons.check, color: AppColors.success),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditingName = false;
                                        _nameController.text = widget.userController.userName;
                                      });
                                    },
                                    icon: const Icon(Icons.close, color: AppColors.error),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.userController.userName.isNotEmpty 
                                        ? widget.userController.userName 
                                        : 'Chưa đặt tên',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _isEditingName = true),
                                    icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Giao diện
            _buildSectionTitle('Giao diện', textPrimary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.themeController.isDarkMode ? 'Chế độ tối' : 'Chế độ sáng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                    ],
                  ),
                  Switch(
                    value: widget.themeController.isDarkMode,
                    onChanged: (value) => widget.themeController.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    ),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Dữ liệu
            _buildSectionTitle('Dữ liệu', textPrimary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.backup, color: AppColors.primary),
                    title: const Text('Sao lưu dữ liệu'),
                    subtitle: Text('Xuất dữ liệu ra file JSON', style: TextStyle(color: textSecondary, fontSize: 12)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.restore, color: AppColors.warning),
                    title: const Text('Khôi phục dữ liệu'),
                    subtitle: Text('Nhập dữ liệu từ file JSON', style: TextStyle(color: textSecondary, fontSize: 12)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text('Xóa toàn bộ dữ liệu'),
                    subtitle: Text('Xóa tất cả từ vựng đã thêm', style: TextStyle(color: textSecondary, fontSize: 12)),
                    onTap: () => _confirmResetData(),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Thông tin
            _buildSectionTitle('Thông tin', textPrimary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Phiên bản', '1.0.0', textPrimary, textSecondary),
                  const Divider(),
                  _buildInfoRow('Số từ đã lưu', '${widget.userController.userName}', textPrimary, textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text('Hành động này sẽ xóa tất cả từ vựng bạn đã thêm. Từ điển có sẵn sẽ không bị ảnh hưởng. Hành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement reset data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
