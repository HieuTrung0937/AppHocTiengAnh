import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Function(String?)? onNotificationTap) async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // ✅ TẤT CẢ THAM SỐ ĐỀU CÓ TÊN (NAMED PARAMETERS)
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );
  }

  Future<void> scheduleReviewNotification({
    required String wordId,
    required String word,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;
    if (scheduledDate.difference(now).inDays > 30) return;

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'memora_review_channel',
          'Ôn tập từ vựng Memora',
          channelDescription:
              'Nhắc nhở ôn tập từ vựng theo thuật toán Spaced Repetition',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          autoCancel: true,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // ✅ TẤT CẢ THAM SỐ ĐỀU CÓ TÊN (NAMED PARAMETERS)
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: wordId.hashCode,
      title: '🧠 Ôn tập nhanh!',
      body: 'Từ "$word" có nghĩa là gì nhỉ? Bấm để kiểm tra thử!',
      scheduledDate: tzScheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: wordId,
    );
  }

  Future<void> cancelNotification(String wordId) async {
    // ✅ THAM SỐ CÓ TÊN
    await flutterLocalNotificationsPlugin.cancel(id: wordId.hashCode);
  }
}
