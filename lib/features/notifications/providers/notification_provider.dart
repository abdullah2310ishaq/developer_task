import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:developer_task/shared/data/services/firestore_notifications_service.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._db, this._local);

  final FirestoreNotificationsService _db;
  final NotificationService _local;

  List<Map<String, dynamic>> items = [];
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  String? _activeUserId;
  bool _seeded = false;
  final Set<String> _knownIds = {};

  int get unreadCount => items.where((n) => n['read'] != true).length;

  bool get hasUnread => unreadCount > 0;

  bool get isListening => _activeUserId != null;

  void startListening(String userId) {
    if (_activeUserId == userId && _sub != null) return;

    stopListening();
    _activeUserId = userId;
    _seeded = false;
    _knownIds.clear();

    _sub = _db.watchUserNotifications(userId).listen((list) async {
      if (_activeUserId != userId) return;

      if (!_seeded) {
        for (final item in list) {
          final id = item['id'] as String?;
          if (id != null) _knownIds.add(id);
        }
        _seeded = true;
      } else {
        for (final item in list) {
          final id = item['id'] as String?;
          if (id == null || _knownIds.contains(id)) continue;

          _knownIds.add(id);
          await _local.showOrderUpdate(
            id: id.hashCode,
            title: item['title'] as String? ?? 'Order update',
            body: item['body'] as String? ?? '',
          );
        }
      }

      items = list;
      notifyListeners();
    });
  }

  void stopListening() {
    _activeUserId = null;
    _seeded = false;
    _knownIds.clear();
    _sub?.cancel();
    _sub = null;
    items = [];
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    if (_activeUserId == null) return;
    await _db.setRead(notificationId, true);
  }

  Future<void> markAsUnread(String notificationId) async {
    if (_activeUserId == null) return;
    await _db.setRead(notificationId, false);
  }

  Future<void> markAllAsRead() async {
    final userId = _activeUserId;
    if (userId == null) return;
    await _db.markAllRead(userId);
  }

  Future<void> initLocal() => _local.init();

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
