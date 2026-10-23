import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/controllers/theme_controller.dart';
import 'package:app_hoc_tieng_anh/features/home/home_screen.dart';
import 'package:app_hoc_tieng_anh/features/vocabulary/vocabulary_screen.dart';
import 'package:app_hoc_tieng_anh/features/review/review_screen.dart';
import 'package:app_hoc_tieng_anh/features/quiz/quiz_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ThemeController _themeController = ThemeController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'StudySpace',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          navigatorKey: _navigatorKey,
          home: MainScreen(themeController: _themeController),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeController themeController;
  const MainScreen({super.key, required this.themeController});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Chỉ giữ HomeScreen trong IndexedStack để tránh mất trạng thái cuộn
  // Các màn hình khác render trực tiếp để giảm tải bộ nhớ
  late final HomeScreen _homeScreen;

  @override
  void initState() {
    super.initState();
    _homeScreen = HomeScreen(themeController: widget.themeController);
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return _homeScreen;
      case 1: return const VocabularyScreen();
      case 2: return const ReviewScreen();
      case 3: return const QuizScreen();
      default: return _homeScreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      // Bỏ IndexedStack, render trực tiếp widget theo index
      body: _getScreen(_currentIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Từ vựng'),
            BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), activeIcon: Icon(Icons.layers), label: 'Ôn tập'),
            BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), activeIcon: Icon(Icons.timer), label: 'Kiểm tra'),
          ],
        ),
      ),
    );
  }
}
