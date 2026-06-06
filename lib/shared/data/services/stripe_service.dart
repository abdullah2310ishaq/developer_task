import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:developer_task/core/config/env_config.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:url_launcher/url_launcher.dart';

/// Stripe checkout — test prototype may use [EnvConfig.stripeSecretKey] directly.
/// Production: move PaymentIntent creation to a backend only.
class StripeService {
  StripeService({Dio? dio}) : _dio = dio ?? Dio();

  static const _stripeApi = 'https://api.stripe.com/v1/payment_intents';

  final Dio _dio;

  bool get hasPaymentLink => EnvConfig.hasStripePaymentLink;

  bool get hasPaymentIntentBackend => EnvConfig.hasStripePaymentIntentBackend;

  bool get hasDirectPaymentIntent => EnvConfig.hasStripeSecretKey;

  bool get canPayInApp => hasDirectPaymentIntent || hasPaymentIntentBackend;

  //fallnack if intent fails
  Future<bool> openPaymentLink() async {
    final url = EnvConfig.stripePaymentLinkUrl;
    if (url.isEmpty) return false;

    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> payCartAmount({required double amount}) async {
    final secret = await _createPaymentIntentClientSecret(amount: amount);
    await presentPaymentSheet(secret);
  }

  Future<String> _createPaymentIntentClientSecret({
    required double amount,
    String currency = 'pkr',
  }) async {
    if (hasDirectPaymentIntent) {
      return _createIntentViaSecretKey(amount: amount, currency: currency);
    }
    return createPaymentIntentClientSecret(amount: amount, currency: currency);
  }

  // intent payemnt test
  Future<String> _createIntentViaSecretKey({
    required double amount,
    String currency = 'pkr',
  }) async {
    final secretKey = EnvConfig.stripeSecretKey;
    if (secretKey.isEmpty) {
      throw StateError('STRIPE_SECRET_KEY missing in .env');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      _stripeApi,
      data: {
        'amount': (amount * 100).round().toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Authorization': 'Bearer $secretKey'},
        responseType: ResponseType.json,
      ),
    );

    final secret = response.data?['client_secret'] as String?;
    if (secret == null || secret.isEmpty) {
      final err = response.data?['error'];
      final message = err is Map ? err['message'] : null;
      throw StateError(message?.toString() ?? 'Invalid Stripe response');
    }
    return secret;
  }

  Future<String> createPaymentIntentClientSecret({
    required double amount,
    String currency = 'pkr',
  }) async {
    final url = EnvConfig.stripePaymentIntentUrl;
    if (url.isEmpty) {
      throw StateError('STRIPE_PAYMENT_INTENT_URL missing in .env');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      url,
      data: {'amount': (amount * 100).round(), 'currency': currency},
    );

    final secret = response.data?['clientSecret'] as String?;
    if (secret == null || secret.isEmpty) {
      throw StateError('Invalid payment intent response');
    }
    return secret;
  }

  Future<void> presentPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Delivery App',
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }

  String formatAmount(double amount) => AppCurrency.format(amount);
}
