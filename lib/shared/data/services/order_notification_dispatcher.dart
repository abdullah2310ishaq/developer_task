import 'package:developer_task/shared/data/services/firestore_notifications_service.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

class OrderNotificationDispatcher {
  OrderNotificationDispatcher(this._db, this._local);

  final FirestoreNotificationsService _db;
  final NotificationService _local;

  String? _sessionUserId;
  final Set<String> _localPingedIds = {};

  void bindSession(String? userId) {
    _sessionUserId = userId;
    if (userId == null) _localPingedIds.clear();
  }

  bool wasPingedLocally(String notificationId) =>
      _localPingedIds.contains(notificationId);

  Future<void> notifyUser({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final docId = await _db.addNotification(
      userId: userId,
      title: title,
      body: body,
      orderId: orderId,
    );

    if (_sessionUserId == userId) {
      await _pingLocal(
        notificationId: docId,
        title: title,
        body: body,
        orderId: orderId,
      );
    }
  }

  Future<void> notifyAdmins({
    required String title,
    required String body,
    String? orderId,
  }) async {
    final adminIds = await _db.fetchAdminUserIds();
    for (final adminId in adminIds) {
      await notifyUser(
        userId: adminId,
        title: title,
        body: body,
        orderId: orderId,
      );
    }
  }

  Future<void> _pingLocal({
    required String notificationId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    if (_localPingedIds.contains(notificationId)) return;

    final enabled = await _local.areNotificationsEnabled();
    if (!enabled) return;

    await _local.showOrderUpdate(
      id: notificationId.hashCode,
      title: title,
      body: body,
    );
    _localPingedIds.add(notificationId);
  }
}
