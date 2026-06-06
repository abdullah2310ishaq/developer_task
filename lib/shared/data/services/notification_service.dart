import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'orders_channel';
  static const _channelName = 'Order updates';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Order status and delivery updates',
        importance: Importance.high,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showOrderUpdate({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Order status and delivery updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
