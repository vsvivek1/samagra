import 'dart:developer';

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
  final String liveServiceUrlGroup1; // New variable
  final String liveServiceUrlLogin; // New variable
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
  }) {
    var a = loadEnv();
  }

  // static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  // factory EnvironmentConfig() {
  //   return _instance;
  // }

  // EnvironmentConfig._internal();

  Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env file: $e");
    }
  }

// Access variables after loading the .env file
  void useEnvVariables() {
    String apiKey = dotenv.env['API_KEY'] ?? 'default_value';
    // Use the extracted variables as needed
    // print("API Key: $apiKey");
  }

  factory EnvironmentConfig.fromEnvFile() {
    // ignore: unused_local_variable

    // print(dotenv);

    String liveServiceUrl = '';
    String liveServiceUrlLogin = '';
    String liveAccessUrl = '';
    String liveServiceUrlGroup1 = '';

    String MODE = dotenv.env['DEPLOYMENT_MODE'] ?? '';

    switch (MODE) {
      case 'MOD_UAT':
        liveServiceUrl = dotenv.env['UAT'] ?? '';
        liveServiceUrlLogin = dotenv.env['UAT'] ?? '';
        liveAccessUrl = dotenv.env['UAT'] ?? '';
        liveServiceUrlGroup1 = dotenv.env['UAT'] ?? '';

        break;
      case 'MOD_UAT_SSO':
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
        break;
      default:
        // Additional logic or handling for other cases
        break;
    }

    debugger(when: true);
    return EnvironmentConfig(
      deploymentMode: dotenv.env['DEPLOYMENT_MODE'] ?? '',
      nasaApiKey: dotenv.env['NASA_API_KEY'] ?? '',
      liveServiceUrlLogin: liveServiceUrlLogin,
      liveServiceUrlGroup1: liveServiceUrlGroup1,
      apiKey: dotenv.env['API_KEY'] ?? '',
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
