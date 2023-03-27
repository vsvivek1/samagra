import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

class InternetConnectivity {
  static Future<bool> checkInternetConnectivity() async {
    //return true;
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static Future<bool> checkServerConnectivity() async {
    try {
      //return true;

      final Map<String, String> data = {
        "email": '1064767@kseberp.in',
        "password": 'uat123',
      };

      final response =
          await Dio().post('http://erpuat.kseb.in/api/login', data: data);
      return response.statusCode == 200;
    } on DioError catch (e) {
      return false;
    }
  }

  static showInternetConnectivityToast(BuildContext context) async {
    bool isInternetConnected = await checkInternetConnectivity();
    bool isServerConnected = await checkServerConnectivity();

    if (!isInternetConnected) {
      Fluttertoast.showToast(
          msg: "No Internet Connection!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (!isServerConnected) {
      Fluttertoast.showToast(
          msg: "Server Connection Failed!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (isServerConnected) {
      // Fluttertoast.showToast(
      //     msg: "Server Connection Successfull",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
  }
}
