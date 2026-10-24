import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/theme_controller.dart';
import 'package:app_hoc_tieng_anh/core/controllers/user_controller.dart';
import 'package:app_hoc_tieng_anh/features/home/components/greeting_header.dart';
import 'package:app_hoc_tieng_anh/features/home/components/daily_progress_card.dart';
import 'package:app_hoc_tieng_anh/features/home/components/quick_actions.dart';
import 'package:app_hoc_tieng_anh/features/home/components/study_statistics.dart';
import 'package:app_hoc_tieng_anh/features/home/components/study_plan_list.dart';
import 'package:app_hoc_tieng_anh/features/settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController themeController;
  final UserController userController;
  
  const HomeScreen({
    super.key, 
    required this.themeController,
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(
                userController: userController,
                onSettingsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen(themeController: themeController)),
                  );
                },
              ),
              const SizedBox(height: 20),
              const DailyProgressCard(),
              const SizedBox(height: 20),
              const QuickActions(),
              const SizedBox(height: 20),
              const StudyStatistics(),
              const SizedBox(height: 20),
              const StudyPlanList(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Bắt đầu ôn tập'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
