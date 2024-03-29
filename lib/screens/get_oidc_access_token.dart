import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:samagra/environmental_config.dart';

Future<List<String>> getOidcAccessTokens(
    String codeVerifier, String code) async {
  EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
  Dio dio = Dio();
  // String url =
  //     'https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/token';

  String url = '${config.liveAccessUrl}token';

  // print(url);

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
    SnackBar(
      content: Text('Some Error $url'),
    );

// Future<List<String>>

    return Future.value(<String>['dummy']);
    // return new ResponseBody(stream, statusCode)
    // throw Exception('Error: $e');
  }
}
