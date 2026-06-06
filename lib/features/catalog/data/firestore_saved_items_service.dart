import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';

class FirestoreSavedItemsService {
  FirestoreSavedItemsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection(FirestorePaths.users).doc(userId);
  }

  Stream<Set<String>> watchSavedProductIds(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return <String>{};
      final raw = doc.data()!['savedProductIds'] as List<dynamic>? ?? [];
      return raw.whereType<String>().toSet();
    });
  }

  Future<void> saveItem(String userId, String productId) {
    return _userDoc(userId).set(
      {'savedProductIds': FieldValue.arrayUnion([productId])},
      SetOptions(merge: true),
    );
  }

  Future<void> removeItem(String userId, String productId) {
    return _userDoc(userId).set(
      {'savedProductIds': FieldValue.arrayRemove([productId])},
      SetOptions(merge: true),
    );
  }
}
