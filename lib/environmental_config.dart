import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  final String apiKey;
  final String erpUrl;
  final String ssoTestServiceUrl;
  final String ssoProductionServiceUrl;
  final String ssoTestAccessUrl;
  final String ssoProductionAccessUrl;
  final String liveAccessUrl; // New variable
  final String liveServiceUrl; // New variable
  final bool isDebug;

  EnvironmentConfig({
    required this.apiKey,
    required this.erpUrl,
    required this.ssoTestServiceUrl,
    required this.ssoProductionServiceUrl,
    required this.ssoTestAccessUrl,
    required this.ssoProductionAccessUrl,
    required this.liveAccessUrl,
    required this.liveServiceUrl,
    required this.isDebug,
  });

  factory EnvironmentConfig.fromEnvFile() {
    dotenv.load(fileName: ".env");
    return EnvironmentConfig(
      apiKey: dotenv.env['API_KEY'] ?? '',
      erpUrl: dotenv.env['ERP_URL'] ?? '',
      ssoTestServiceUrl: dotenv.env['SSO_TEST_SERVICE_URL'] ?? '',
      ssoProductionServiceUrl: dotenv.env['SSO_PRODUCTION_SERVICE_URL'] ?? '',
      ssoTestAccessUrl: dotenv.env['SSO_TEST_ACCESS_URL'] ?? '',
      ssoProductionAccessUrl: dotenv.env['SSO_PRODUCTION_ACCESS_URL'] ?? '',
      liveAccessUrl: dotenv.env['LIVE_ACCESS_URL'] ?? '', // Load new variable
      liveServiceUrl: dotenv.env['LIVE_SERVICE_URL'] ?? '', // Load new variable
      isDebug: dotenv.env['DEBUG'] == 'true',
    );
  }
}
