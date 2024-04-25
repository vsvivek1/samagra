import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/environmental_config.dart';

class MyAPI {
  final Dio _dio = Dio();
  late EnvironmentConfig config;

  Future<void> initializeConfig() async {
    config = await EnvironmentConfig.fromEnvFile();
  }

  Future login(String email, String password, String showPhoto, context) async {
    initializeConfig();
    final String _url = "${config.liveServiceUrl}login";
    final Map<String, String> data = {
      "email": email,
      "password": password,
      "show_photo": showPhoto
    };

    try {
      print(_url);
      Response response = await _dio.post(_url, data: data);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            content: Text('Too many requests and Load /server busy'),
            duration: Duration(seconds: 3))));

        var result;

        return Future(() => result);
      }

      if (response.statusCode != 200 || response.data['result_flag'] == -1) {
        // String resultMessage = response['result_message'];

        // String resultMessage = response.result_message;

        // ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        //     content: Text("$resultMessage"), duration: Duration(seconds: 3))));

        return -1;
      }
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e);
      } else {
        // print(e.request);
      }
      throw e;
    }
  }
}
