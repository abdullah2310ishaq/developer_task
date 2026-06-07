import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  factory NotificationService() => instance;

  static const _channelId = 'orders_channel';
  static const _channelName = 'Order updates';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);

    await _androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Order status and delivery updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    _ready = true;
  }

  Future<bool> requestPermission() async {
    await init();

    final androidPlugin = _androidPlugin;
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted == true) return true;
    }

    if (await Permission.notification.isGranted) return true;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> areNotificationsEnabled() async {
    await init();

    final androidEnabled = await _androidPlugin?.areNotificationsEnabled();
    if (androidEnabled != null) return androidEnabled;

    return Permission.notification.isGranted;
  }

  Future<void> showOrderUpdate({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();

    if (!await areNotificationsEnabled()) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Order status and delivery updates',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
    );

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('showOrderUpdate failed: $e');
      }
    }
  }
}
