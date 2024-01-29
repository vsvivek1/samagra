import 'dart:async';
// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';

final SecureStorage _secureStorage = SecureStorage();

late EnvironmentConfig
    config; //=instanceof(config, EnvironmentConfig) as EnvironmentConfig;

Future<void> initializeConfigIfNeeded() async {
  config = await EnvironmentConfig.fromEnvFile();
  if (config == null) {
    config = await EnvironmentConfig.fromEnvFile();
  }
}

Future<void> refreshAccessToken(refreshToken) async {
  await initializeConfigIfNeeded();

  if (!config.deploymentMode.contains('SSO')) {
    return;
  }
  try {
    Dio dio = Dio();

    var formData = {
      'client_id': 'pkce-client3',
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken, // Replace with your refresh token
    };

    String url = '${config.liveAccessUrl}token';
    debugPrint(url);
    var response = await dio.post(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: FormData.fromMap(formData),
    );

    if (response.statusCode == 200) {
      // Handle successful token refresh response
      debugPrint('Token refreshed successfully: ${response.data}');
    } else {
      // Handle other status codes
      debugPrint('Failed to refresh token: ${response.statusCode}');
    }
  } catch (e) {
    // Handle Dio errors
    debugPrint('Error refreshing token: $e');
  }
}

void startJwtExpiryCheck() async {
  await initializeConfigIfNeeded();
  if (!config.deploymentMode.contains('SSO')) {
    return;
  }
  String jwtToken = await getJwtTokenFromStorage();

  if (jwtToken.isEmpty) {
    return;
  }
  const duration = Duration(seconds: 60); // Check every 30 seconds
  Timer _timer = Timer.periodic(duration, (timer) {
    // debugPrint(jwtToken);

    //  if(deplo)
    checkJwtExpiry(jwtToken);
  });
}

Future<String> getJwtTokenFromStorage() async {
  var res = await _secureStorage.getSecureStorageDataByKey("access_token");
  return res ?? '';
}

Future<String> getRefrfeshTokenFromStorage() async {
  return await _secureStorage.getSecureStorageDataByKey("refresh_token");
}

void checkJwtExpiry(jwtToken) async {
  if (jwtToken == '' || jwtToken == null) {
    return;
  }

  await initializeConfigIfNeeded();
  if (!config.deploymentMode.contains('SSO')) {
    return;
  }

  Map<String, dynamic> decodedToken = Jwt.parseJwt(jwtToken);

  if (decodedToken.containsKey('exp')) {
    double expiryTimeInSeconds = decodedToken['exp'].toDouble();
    double currentTimeInSeconds =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toDouble();

    double remainingSeconds = expiryTimeInSeconds - currentTimeInSeconds;

    if (remainingSeconds <= 60 && remainingSeconds > 0) {
      String refreshToken = await getRefrfeshTokenFromStorage();
      // refreshAccessToken(refreshToken);
      showExpiryToast();
    } else {
      String refreshToken = await getRefrfeshTokenFromStorage();
      // refreshAccessToken(refreshToken);
      // showExpiryToast();
      debugPrint('JWT is not about to expire. ${remainingSeconds}');
    }
  } else {
    debugPrint('Token does not contain expiration time.');
  }
}

void showExpiryToast() async {
  await initializeConfigIfNeeded();
  if (!config.deploymentMode.contains('SSO')) {
    return;
  }
  Fluttertoast.showToast(
    msg: 'JWT is about to expire in less than 1 minute!',
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}
