import 'dart:async';
// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/get_user_info.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';

final SecureStorage _secureStorage = SecureStorage();
late EnvironmentConfig config;

/// Initialize the configuration if not already done
Future<void> initializeConfigIfNeeded() async {
  config = await EnvironmentConfig.fromEnvFile();
}

/// Refresh the access token using the refresh token
Future<void> refreshAccessToken(String refreshToken) async {
  await initializeConfigIfNeeded();

  if (!config.deploymentMode.contains('SSO')) {
    return;
  }

  try {
    Dio dio = Dio();
    var formData = {
      'client_id': 'pkce-client3',
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    };

    String url = '${config.liveAccessUrl}token';
    print('Refreshing token with URL: $url');

    var response = await dio.post(
      url,
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
      data: formData,
    );

    if (response.statusCode == 200) {
      String accessToken = response.data['access_token'];
      setAccessTokenToStorage(accessToken);
      getUserInfo(accessToken, false); // Pass `_ssoLoginLoading` as `false`
      print('Token refreshed successfully');
    } else {
      print('Failed to refresh token: ${response.statusCode}');
    }
  } catch (e) {
    print('Error refreshing token: $e');
  }
}

/// Periodically checks for JWT token expiry and refreshes if needed
void startJwtExpiryCheck() async {
  await initializeConfigIfNeeded();

  if (!config.deploymentMode.contains('SSO')) {
    return;
  }

  String jwtToken = await getJwtTokenFromStorage();

  if (jwtToken.isEmpty) {
    print('JWT token is empty. Exiting expiry check.');
    return;
  }

  const duration = Duration(seconds: 60); // Check every minute
  Timer.periodic(duration, (timer) => checkJwtExpiry(jwtToken));
}

/// Fetch the JWT token from secure storage
Future<String> getJwtTokenFromStorage() async {
  try {
    var res = await _secureStorage.getSecureStorageDataByKey("access_token");
    return res ?? '';
  } catch (e) {
    print('Error fetching JWT token: $e');
    return '';
  }
}

/// Fetch the refresh token from secure storage
Future<String> getRefreshTokenFromStorage() async {
  try {
    var res = await _secureStorage.getSecureStorageDataByKey("refresh_token");
    return res ?? '';
  } catch (e) {
    print('Error fetching refresh token: $e');
    return '';
  }
}

/// Save the access token to secure storage
void setAccessTokenToStorage(String accessToken) async {
  try {
    await _secureStorage.writeKeyValuePairToSecureStorage(
        'access_token', accessToken);
  } catch (e) {
    print('Error saving access token: $e');
  }
}

/// Save the refresh token to secure storage
void setRefreshTokenToStorage(String refreshToken) async {
  try {
    await _secureStorage.writeKeyValuePairToSecureStorage(
        'refresh_token', refreshToken);
  } catch (e) {
    print('Error saving refresh token: $e');
  }
}

/// Check if the JWT token is about to expire
void checkJwtExpiry(String jwtToken) async {
  if (jwtToken.isEmpty) {
    return;
  }

  await initializeConfigIfNeeded();

  if (!config.deploymentMode.contains('SSO')) {
    return;
  }

  try {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(jwtToken);

    if (decodedToken.containsKey('exp')) {
      double expiryTimeInSeconds = decodedToken['exp'].toDouble();
      double currentTimeInSeconds =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toDouble();

      double remainingSeconds = expiryTimeInSeconds - currentTimeInSeconds;

      if (remainingSeconds <= 60 && remainingSeconds > 0) {
        String refreshToken = await getRefreshTokenFromStorage();
        await refreshAccessToken(refreshToken);
        showExpiryToast();
      } else {
        print(
            'JWT is not about to expire. Remaining seconds: $remainingSeconds');
      }
    } else {
      print('Token does not contain expiration time.');
    }
  } catch (e) {
    print('Error checking JWT expiry: $e');
  }
}

/// Show a toast notification about token expiry
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
