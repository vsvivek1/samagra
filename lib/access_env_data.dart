import 'package:flutter_dotenv/flutter_dotenv.dart';

void accessEnvData() async {
  await dotenv.load(fileName: ".env");

  // Fetching values from the .env file
  String apiKey = dotenv.env['API_KEY'] ?? '';
  String erpUrl = dotenv.env['ERP_URL'] ?? '';
  String ssoTestServiceUrl = dotenv.env['SSO_TEST_SERVICE_URL'] ?? '';
  String ssoProductionServiceUrl =
      dotenv.env['SSO_PRODUCTION_SERVICE_URL'] ?? '';
  String ssoTestAccessUrl = dotenv.env['SSO_TEST_ACCESS_URL'] ?? '';
  String ssoProductionAccessUrl = dotenv.env['SSO_PRODUCTION_ACCESS_URL'] ?? '';
  bool isDebug = dotenv.env['DEBUG'] == 'true';
}
