import 'dart:developer';

import 'package:dio/dio.dart';

Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
  Dio dio = Dio();
  String url = 'https://hris.kseb.in/ipdstest/api/erp/auth/getUserInfo';

  try {
    // Set up headers with the access token
    dio.options.headers['Authorization'] = 'Bearer $accessToken';

    Response response = await dio.post(url);

    debugger(when: true);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get user info: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
