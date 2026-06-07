import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get cloudinaryCloudName {
    return _required('CLOUDINARY_CLOUD_NAME');
  }

  static String get cloudinaryUploadPreset {
    return _required('CLOUDINARY_UPLOAD_PRESET');
  }

  static String get cloudinaryUploadUrl {
    return 'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';
  }

  static String get stripePublishableKey {
    return _required('STRIPE_PUBLISHABLE_KEY');
  }

  static String get stripePaymentIntentUrl {
    String? value = dotenv.env['STRIPE_PAYMENT_INTENT_URL'];
    if (value == null) {
      return '';
    }
    return value.trim();
  }

  static bool get hasStripePaymentIntentBackend {
    return stripePaymentIntentUrl.isNotEmpty;
  }

  static String get stripePaymentLinkUrl {
    String? value = dotenv.env['STRIPE_PAYMENT_LINK_URL'];
    if (value == null) {
      return '';
    }
    return value.trim();
  }

  static bool get hasStripePaymentLink {
    return stripePaymentLinkUrl.isNotEmpty;
  }

  static String get stripeSecretKey {
    String? value = dotenv.env['STRIPE_SECRET_KEY'];
    if (value == null) {
      return '';
    }
    return value.trim();
  }

  static bool get hasStripeSecretKey {
    return stripeSecretKey.isNotEmpty;
  }

  static String? get googleWebClientId {
    return dotenv.env['GOOGLE_WEB_CLIENT_ID'];
  }

  /// Optional fallback when Firestore cannot query admin users (rules).
  /// Comma-separated Firebase Auth UIDs, e.g. ADMIN_NOTIFY_USER_IDS=uid1,uid2
  static List<String> get adminNotifyUserIds {
    final raw = dotenv.env['ADMIN_NOTIFY_USER_IDS'];
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
  }

  static String _required(String key) {
    String? value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Missing $key in .env — copy .env.example to .env and fill values. See ENV_SETUP.md',
      );
    }
    return value.trim();
  }
}
