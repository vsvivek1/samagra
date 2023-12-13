import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:samagra/environmental_config.dart';

EnvironmentConfig config = EnvironmentConfig.fromEnvFile();

Future<List<String>> getOidcAccessTokens(
    String codeVerifier, String code) async {
  Dio dio = Dio();
  // String url =
  //     'https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/token';

  String url = '${config.liveAccessUrl}/token';

  try {
    Response response = await dio.post(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'code': code,
        'client_id': 'pkce-client3',
        'redirect_uri': 'm-samagra://kseb.in/sso',
        'grant_type': 'authorization_code',
        'code_verifier': codeVerifier,
      },
    );

    // debugger(when: true);
    if (response.statusCode == 200) {
      String accessToken = response.data['access_token'];
      String refreshToken = response.data['refresh_token'];
      return [accessToken, refreshToken];
    } else {
      throw Exception('Failed to get token: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
