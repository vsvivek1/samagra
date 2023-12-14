import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/environmental_config.dart';

Future getUserInfo(String accessToken) async {
  Dio dio = Dio();

  EnvironmentConfig config = EnvironmentConfig.fromEnvFile();
  String url = '${config.liveServiceUrl}/auth1/getUserInfo';

  String apiKey = '${config.apiKey}';

  try {
    // EnvironmentConfig config = EnvironmentConfig.fromEnvFile();
    // Set up headers with the access token and API key
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    dio.options.headers['x-api-key'] =
        '${apiKey}'; // Replace with your actual API key

    Response response = await dio.post(url);
    debugger(when: true);

    return response.data;

    // You might return null or handle this differently based on your use case

    // You might return null or handle this differently based on your use case
    // return response.data;
  } catch (e) {
    return e;

    throw Exception('Error: $e');
  }
}
