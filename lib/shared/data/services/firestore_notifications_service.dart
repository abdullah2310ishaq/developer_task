import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/config/env_config.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';
import 'package:developer_task/features/auth/models/user_role.dart';

class FirestoreNotificationsService {
  FirestoreNotificationsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(FirestorePaths.notifications);

  Stream<List<Map<String, dynamic>>> watchUserNotifications(String userId) {
    return _notifications.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        final list = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        list.sort((a, b) {
          final timeA = a['createdAt'] as Timestamp?;
          final timeB = b['createdAt'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA);
        });

        return list;
      },
    );
  }

  Future<List<String>> fetchAdminUserIds() async {
    try {
      final snap = await _firestore
          .collection(FirestorePaths.users)
          .where('role', isEqualTo: const RoleAdmin().firestoreValue)
          .get();

      final ids = snap.docs.map((doc) => doc.id).toList();
      if (ids.isNotEmpty) return ids;
    } catch (_) {}

    return EnvConfig.adminNotifyUserIds;
  }

  Future<String> addNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final doc = await _notifications.add({
      'userId': userId,
      'title': title,
      'body': body,
      'orderId': orderId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> setRead(String notificationId, bool read) {
    return _notifications.doc(notificationId).update({'read': read});
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _notifications
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
