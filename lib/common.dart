import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage/secure_storage.dart';

import 'package:intl/intl.dart';

String getDateAndWeek() {
  DateTime now = DateTime.now();

  String formattedDate = DateFormat('d MMM y, EEEE').format(now);

  return formattedDate;
}

Future<String> Token() async {
  final secureStorage = FlutterSecureStorage();
  final accessToken = await secureStorage.read(key: 'access_token');
  return Future.value(accessToken);
}

Future<String> getAccessToken() async {
  final secureStorage = FlutterSecureStorage();
  final accessToken = await secureStorage.read(key: 'access_token');
  return Future.value(accessToken);
}

Map getCurrentSeatDetails(loginDeatails1) {
  Map loginDetails = json.decode(loginDeatails1);

  int currentSeatId = loginDetails['user']!['current_seat_id'] ?? -1;

  var seats = loginDetails['user']!['seats'] ?? [];

  if (seats == []) {
    return {};
  }

  Map<String, dynamic> selectedSeat = seats.firstWhere(
    (seat) => seat['mst_seat_id'] == currentSeatId,
    orElse: () => null,
  );

  return selectedSeat;
}

Future<Object> getUserLoginDetails() async {
  var _secureStorage = SecureStorage();
  var _loginDetails1 =
      await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

  if (!_loginDetails1?.isEmpty) {
    var ob = json.decode(_loginDetails1["loginDetails"] ?? '');

    ob["seat_details"] = getCurrentSeatDetails(_loginDetails1["loginDetails"]);

    return Future.value(ob);
  } else {
    var ob = {};

    ob["seat_details"] = '';

    return Future.value(ob);
  }
}
