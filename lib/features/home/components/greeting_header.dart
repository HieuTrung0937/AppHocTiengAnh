import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/user_controller.dart';

class GreetingHeader extends StatelessWidget {
  final UserController userController;
  final VoidCallback onSettingsTap;
  
  const GreetingHeader({
    super.key, 
    required this.userController,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.headlineMedium?.color ?? AppColors.textPrimary;
    final textHint = Theme.of(context).textTheme.labelSmall?.color ?? AppColors.textHint;
    
    // Lấy tên từ UserController, fallback về "bạn" nếu chưa có
    final userName = userController.userName.isNotEmpty ? userController.userName : 'bạn';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STUDYSPACE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textHint, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(
                'Chào $userName, hãy ôn từ vựng hôm nay.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onSettingsTap,
          icon: Icon(Icons.settings_outlined, color: Theme.of(context).iconTheme.color ?? AppColors.textSecondary),
        ),
      ],
    );
  }
}
