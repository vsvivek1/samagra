import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future getUserInfo(String accessToken) async {
  Dio dio = Dio();
  String url = 'https://hris.kseb.in/ipdstest/api/erp/auth/getUserInfo';

  try {
    // Set up headers with the access token and API key
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    dio.options.headers['x-api-key'] =
        'a57a53b49a258aa97021735f9b9540709004fd0ae0a583a12f24590d17c78691d4249be46dd20dae'; // Replace with your actual API key

    Response response = await dio.post(url);

    return response.data;

    // You might return null or handle this differently based on your use case

    // You might return null or handle this differently based on your use case
    // return response.data;
  } catch (e) {
    return e;

    throw Exception('Error: $e');
  }
}
