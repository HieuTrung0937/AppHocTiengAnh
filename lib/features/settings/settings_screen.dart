import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController;
  const SettingsScreen({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: colorScheme.background,
      ),
      backgroundColor: colorScheme.background,
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Chế độ tối', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text('Giảm ánh sáng xanh khi học vào ban đêm', style: TextStyle(color: textSecondary, fontSize: 12)),
            secondary: Icon(
              themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            value: themeController.isDarkMode,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.5),
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.surfaceVariant,
            onChanged: (value) {
              // Gọi toggleTheme để tự động đảo trạng thái
              themeController.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
            title: Text('Phiên bản ứng dụng', style: TextStyle(color: textColor)),
            subtitle: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
