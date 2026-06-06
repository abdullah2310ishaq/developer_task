import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';

class FirestoreNotificationsService {
  final FirebaseFirestore _firestore;

  FirestoreNotificationsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Notifications retrun func
  CollectionReference<Map<String, dynamic>> getNotificationsCollection() {
    return _firestore.collection(FirestorePaths.notifications);
  }

  Stream<List<Map<String, dynamic>>> watchUserNotifications(String userId) {
    CollectionReference<Map<String, dynamic>> collection =
        getNotificationsCollection();

    // Firestore se data filter karke mangwana
    return collection.where('userId', isEqualTo: userId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      List<Map<String, dynamic>> notificationsList = [];

      //data saving inlist
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        notificationsList.add(data);
      }

      notificationsList.sort((a, b) {
        Timestamp? timeA = a['createdAt'] as Timestamp?;
        Timestamp? timeB = b['createdAt'] as Timestamp?;

        // Agar kisi ka time missing ho toh sorting skip karna
        if (timeA == null || timeB == null) {
          return 0;
        }
        return timeB.compareTo(timeA);
      });

      return notificationsList;
    });
  }

  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final collection = getNotificationsCollection();

    await collection.add({
      'userId': userId,
      'title': title,
      'body': body,
      'orderId': orderId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setRead(String notificationId, bool read) {
    return getNotificationsCollection().doc(notificationId).update({'read': read});
  }

  Future<void> markAllRead(String userId) async {
    final snap = await getNotificationsCollection()
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
