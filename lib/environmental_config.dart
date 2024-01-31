import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  final String apiKey;
  final String erpUrl;
  final String ssoTestServiceUrl;
  final String ssoProductionServiceUrl;
  final String ssoTestAccessUrl;
  final String ssoProductionAccessUrl;
  final String liveAccessUrl;
  final String liveServiceUrl;
  final String liveServiceUrlGroup1;
  final String liveServiceUrlLogin;
  final bool isDebug;

  String nasaApiKey;
  String deploymentMode;

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
    required String apiKeyProd,
    required this.liveServiceUrlGroup1,
    required this.liveServiceUrlLogin,
    required this.nasaApiKey,
    required this.deploymentMode,
  });

  static Future<EnvironmentConfig> fromEnvFile() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env file: $e");
      // Handle the error appropriately (throw/recover)
    }

    String liveServiceUrl = '';
    String liveServiceUrlLogin = '';
    String liveAccessUrl = '';
    String liveServiceUrlGroup1 = '';
    String apiKey = '';

    String MODE = dotenv.env['DEPLOYMENT_MODE'] ?? '';

    switch (MODE) {
      case 'MOD_UAT':
        liveServiceUrl = dotenv.env['UAT'] ?? '';
        liveServiceUrlLogin = dotenv.env['UAT'] ?? '';
        liveAccessUrl = dotenv.env['UAT'] ?? '';
        liveServiceUrlGroup1 = dotenv.env['UAT'] ?? '';
        apiKey = dotenv.env['API_KEY_TEST'] ?? '';

        break;
      case 'MOD_UAT_SSO':
        liveServiceUrl = dotenv.env['TEST_SERVICE_URL'] ?? '';
        liveServiceUrlLogin = dotenv.env['TEST_SERVICE_URL_LOGIN'] ?? '';
        liveAccessUrl = dotenv.env['TEST_ACCESS_URL'] ?? '';
        liveServiceUrlGroup1 = dotenv.env['TEST_SERVICE_URL_GROUP1'] ?? '';
        apiKey = dotenv.env['API_KEY_TEST'] ?? '';

        // MOD_UAT_SSO
        // Additional logic if needed
        break;
      case 'MOD_PRODUCTION':
        // Additional logic if needed
        break;
      case 'MOD_PRODUCTION_SSO':
        liveServiceUrl = dotenv.env['LIVE_SERVICE_URL'] ?? '';
        liveServiceUrlLogin = dotenv.env['LIVE_SERVICE_URL_LOGIN'] ?? '';
        liveAccessUrl = dotenv.env['LIVE_ACCESS_URL'] ?? '';
        liveServiceUrlGroup1 = dotenv.env['LIVE_SERVICE_URL_GROUP1'] ?? '';
        apiKey = dotenv.env['API_KEY_PROD'] ?? '';
        break;
      default:
        // Additional logic or handling for other cases
        break;
    }

    return EnvironmentConfig(
      deploymentMode: MODE,
      nasaApiKey: dotenv.env['NASA_API_KEY'] ?? '',
      liveServiceUrlLogin: liveServiceUrlLogin,
      liveServiceUrlGroup1: liveServiceUrlGroup1,
      apiKey: apiKey,
      apiKeyProd: dotenv.env['API_KEY_PROD'] ?? '',
      erpUrl: dotenv.env['ERP_URL'] ?? '',
      ssoTestServiceUrl: dotenv.env['SSO_TEST_SERVICE_URL'] ?? '',
      ssoProductionServiceUrl: dotenv.env['SSO_PRODUCTION_SERVICE_URL'] ?? '',
      ssoTestAccessUrl: dotenv.env['SSO_TEST_ACCESS_URL'] ?? '',
      ssoProductionAccessUrl: dotenv.env['SSO_PRODUCTION_ACCESS_URL'] ?? '',
      liveAccessUrl: liveAccessUrl,
      liveServiceUrl: liveServiceUrl,
      isDebug: dotenv.env['DEBUG'] == 'true',
    );
  }
}
