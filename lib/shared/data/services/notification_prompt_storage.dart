import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationPromptStorage {
  NotificationPromptStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _askedKey = 'notification_prompt_asked';

  final FlutterSecureStorage _storage;

  Future<bool> wasAsked() async {
    final value = await _storage.read(key: _askedKey);
    return value == 'true';
  }

  Future<void> markAsked() async {
    await _storage.write(key: _askedKey, value: 'true');
  }
}
