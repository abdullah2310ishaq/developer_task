import 'package:developer_task/features/auth/models/user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.phone,
    this.address,
    this.profileComplete = false,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? phone;
  final String? address;
  final bool profileComplete;
  final UserRole role;

  bool get needsProfileSetup => !profileComplete && role is RoleUser;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      profileComplete: map['profileComplete'] as bool? ?? false,
      role: UserRole.fromFirestore(map['role'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'address': address,
      'profileComplete': profileComplete,
      'role': role.firestoreValue,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? phone,
    String? address,
    bool? profileComplete,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }
}
