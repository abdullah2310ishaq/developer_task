import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';
import 'package:developer_task/features/auth/models/app_user.dart';
import 'package:developer_task/features/auth/models/user_role.dart';

class AuthUserService {
  AuthUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<AppUser> ensureGoogleUser({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    final existing = await fetchUser(uid);
    if (existing != null) return existing;

    final user = AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      role: const RoleUser(),
      profileComplete: false,
    );

    await _users.doc(uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  Future<AppUser> saveProfile({
    required String uid,
    required String displayName,
    required String phone,
    required String address,
  }) async {
    final data = {
      'displayName': displayName.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(uid).set(data, SetOptions(merge: true));
    final updated = await fetchUser(uid);
    if (updated == null) throw StateError('Profile save failed');
    return updated;
  }
}
