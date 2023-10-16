import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/get_login_details.dart';

import 'log_functions.dart';
import 'package:dio/dio.dart';

Future<Map<String, dynamic>?> getWorkDetails(String workId,
    {measurementsetListId = '-1'}) async {
  // debugger(when: true);

  // debugger(when: true);
  logCurrentFunction();
  final storage = FlutterSecureStorage();
  // Get existing work details from secure storage, if any
  final existingDetails = await storage.read(key: 'workDetails') ?? '{}';

  final workDetails = Map<String, dynamic>.from(json.decode(existingDetails));

  // debugger(when: true);

  // Return work details for the given workId, if present
  final workData = workDetails[workId];

  if (measurementsetListId != '-1') {
    var measurementDetailsfromServer =
        await getWorkDertailsFromServer(measurementsetListId);

    // debugger(when: true);
    if (measurementDetailsfromServer != null) {
      print('measurementDetailsFrom server');

      var ob = {};
      ob[workId] = measurementDetailsfromServer;

      workData['measurementDetails'] = Map<String, dynamic>.from(ob);
    }
  }

  // print(workData);
  // debugger(when: true);
  // print('workada ta ar 217');

  // return;

  if (workData != null) {
    print("workData['measurementDetails'] ${workData['measurementDetails']}");
    // debugger(when: true);
    return Map<String, dynamic>.from(workData);
  } else {
    return null;
  }
}

getWorkDertailsFromServer(measurementsetListId) async {
  // String seatId = await getSeatId();

  final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
  String url =
      "http://erpuat.kseb.in/api/wrk/getPolevarMeasurementDetails/$measurementsetListId";

  print(url);

  Response<Map<String, dynamic>> res = await Dio().get(
    url,
    options: Options(headers: headers),
  );

  var dta = res.data;
  if (dta!["result_flag"] == 1) {
    return dta['result_data']['data'];
    // print(dta['result_data']['data']);
  } else {
    return [];
  }
  // print(res);

  // debugger(when: true);
}
