import 'package:dio/dio.dart';
import 'package:samagra/check_jwt_expiry.dart';
import 'package:samagra/environmental_config.dart';

setDioAccessokenAndApiKey(
    Dio dio, String accessToken, EnvironmentConfig config) {
  ///check access token validity
  ///
  ///if invalid using refresh token  refresh the token and  call get user info
  checkJwtExpiry(accessToken);

  dio.options.headers['Authorization'] = 'Bearer $accessToken';

  String apiKey = '${config.apiKey}';

  dio.options.headers['x-api-key'] =
      '$apiKey'; // Replace with your actual API key

  return dio;
  //debugger(when: true);
  // debugger(when: true);
}
