sealed class UserRole {
  const UserRole();

  String get firestoreValue;

  bool get isAdmin => this is RoleAdmin;

  static UserRole fromFirestore(String? raw) {
    return switch (raw) {
      'admin' => const RoleAdmin(),
      _ => const RoleUser(),
    };
  }
}

final class RoleUser extends UserRole {
  const RoleUser();

  @override
  String get firestoreValue => 'user';
}

final class RoleAdmin extends UserRole {
  const RoleAdmin();

  @override
  String get firestoreValue => 'admin';
}

enum AuthLoginTarget {
  user,
  admin;

  String get title => switch (this) {
        AuthLoginTarget.user => 'Customer',
        AuthLoginTarget.admin => 'Admin',
      };
}
