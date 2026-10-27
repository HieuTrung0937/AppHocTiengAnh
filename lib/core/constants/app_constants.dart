/// Các hằng số chung của ứng dụng
class AppConstants {
  // Tên ứng dụng
  static const String appName = 'StudySpace';

  // Cấu hình thuật toán Priority
  static const double weightTime = 0.4;
  static const double weightErrorRate = 0.4;
  static const double weightDifficulty = 0.2;

  // Cấu hình ôn tập
  static const int dailyGoalMinutes = 90;
  static const int maxWordsPerReview = 20;
  static const int maxWordsPerQuiz = 10;

  // Khoảng thời gian ôn tập (ngày)
  static const int reviewIntervalAgain = 0;    // Chưa nhớ: ôn lại ngay
  static const int reviewIntervalHard = 2;     // Nhớ một phần: 2 ngày
  static const int reviewIntervalGood = 7;     // Đã nhớ: 1 tuần
  static const int reviewIntervalEasy = 14;    // Nhớ tốt: 2 tuần

  // Danh mục từ vựng
  static const List<String> categories = [
    'Môi trường',
    'Học tập',
    'Cuộc sống',
    'Khoa học',
  ];

  // Các chế độ kiểm tra
  static const List<String> quizModes = [
    'Chọn nghĩa',
    'Điền từ',
    'Luyện nghe',
  ];
}
