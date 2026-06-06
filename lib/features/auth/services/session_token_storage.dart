import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSession {
  const StoredSession({
    required this.token,
    required this.uid,
    required this.expiresAt,
  });

  final String token;
  final String uid;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining => expiresAt.difference(DateTime.now());
}

class SessionTokenStorage {
  SessionTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const sessionDuration = Duration(minutes: 30);

  static const _tokenKey = 'auth_session_token';
  static const _uidKey = 'auth_session_uid';
  static const _expiresKey = 'auth_session_expires_at';

  final FlutterSecureStorage _storage;

  Future<StoredSession> saveSession({
    required String token,
    required String uid,
  }) async {
    final expiresAt = DateTime.now().add(sessionDuration);
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _uidKey, value: uid),
      _storage.write(key: _expiresKey, value: expiresAt.toIso8601String()),
    ]);
    return StoredSession(token: token, uid: uid, expiresAt: expiresAt);
  }

  Future<StoredSession?> readSession() async {
    final token = await _storage.read(key: _tokenKey);
    final uid = await _storage.read(key: _uidKey);
    final expiresRaw = await _storage.read(key: _expiresKey);
    if (token == null || uid == null || expiresRaw == null) return null;

    final expiresAt = DateTime.tryParse(expiresRaw);
    if (expiresAt == null) return null;

    return StoredSession(token: token, uid: uid, expiresAt: expiresAt);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _uidKey),
      _storage.delete(key: _expiresKey),
    ]);
  }
}
