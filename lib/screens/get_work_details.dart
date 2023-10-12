import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'log_functions.dart';
import 'package:dio/dio.dart';

Future<Map<String, dynamic>?> getWorkDetails(String workId,
    {measurementsetListId = -1}) async {
  if (measurementsetListId != -1) {
    var workDataFromServer =
        await getWorkDertailsFromServer(measurementsetListId);

    if (workDataFromServer != null) {
      return Map<String, dynamic>.from(workDataFromServer);
    } else {
      return null;
    }
  }

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

getWorkDertailsFromServer(measurementsetListId) {}
