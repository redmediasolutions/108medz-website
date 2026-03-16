import 'dart:io';

class WCServerSecrets {
  // Allow overriding secrets via environment variables on the server.
  static String get consumerKey =>
      Platform.environment['WC_CONSUMER_KEY'] ?? _fallbackKey;
  static String get consumerSecret =>
      Platform.environment['WC_CONSUMER_SECRET'] ?? _fallbackSecret;

  static bool get usingFallback =>
      Platform.environment['WC_CONSUMER_KEY'] == null ||
      Platform.environment['WC_CONSUMER_SECRET'] == null;

  // Keep fallback values for local dev; set env vars in production.
  static const String _fallbackKey =
      "ck_2c76c1dd9567814ed5696a3b24fa4f2bb29654aa";
  static const String _fallbackSecret =
      "cs_b1493a50c08fc9c3fc56ede56fc600fc9e14bd7f";
}
