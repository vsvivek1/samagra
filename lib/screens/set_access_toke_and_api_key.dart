import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:samagra/environmental_config.dart';

void setDioAccessokenAndApiKey(
    Dio dio, String accessToken, EnvironmentConfig config) {
  dio.options.headers['Authorization'] = 'Bearer $accessToken';

  String apiKey = '${config.apiKey}';
  dio.options.headers['x-api-key'] =
      '$apiKey'; // Replace with your actual API key

  // debugger(when: true);
}
