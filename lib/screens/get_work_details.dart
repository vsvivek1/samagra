import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/get_login_details.dart';

import 'log_functions.dart';
import 'package:dio/dio.dart';

Future<Map<String, dynamic>?> getWorkDetails(String workId,
    {measurementsetListId = '-1'}) async {
  if (measurementsetListId != '-1') {
    var workDataFromServer =
        await getWorkDertailsFromServer(measurementsetListId);

    debugger(when: true);

    if (workDataFromServer != null) {
      return Map<String, dynamic>.from(workDataFromServer);
    } else {
      return null;
    }
  }
  // debugger(when: true);
  logCurrentFunction();
  final storage = FlutterSecureStorage();
  // Get existing work details from secure storage, if any
  final existingDetails = await storage.read(key: 'workDetails') ?? '{}';
  final workDetails = Map<String, dynamic>.from(json.decode(existingDetails));

  // Return work details for the given workId, if present
  final workData = workDetails[workId];

  // print(workData);

  // print('workada ta ar 217');

  // return;
  if (workData != null) {
    return Map<String, dynamic>.from(workData);
  } else {
    return null;
  }
}

getWorkDertailsFromServer(measurementsetListId) async {
  String seatId = await getSeatId();

  final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
  String url =
      "http://erpuat.kseb.in/api/wrk/getPolevarMeasurementDetails/$seatId";

  print(url);

  var res = await Dio().get(
    url,
    options: Options(headers: headers),
  );

  print(res);

  debugger(when: true);
}
