import 'package:samagra/secure_storage/secure_storage.dart';
import 'dart:convert';

var _secureStorage = SecureStorage();

Future<String> _getUserLoginDetails() async {
  var _loginDetails1 =
      await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

  return _loginDetails1["loginDetails"]; //.toString();
}

void p(msg) {
  print('-----------------------');

  print(msg);
  print('-----------------------');
}

Map getCurrentSeatDetails(loginDeatails1) {
  Map loginDetails = json.decode(loginDeatails1);

  int currentSeatId = loginDetails['user']!['current_seat_id'] ?? -1;

  var seats = loginDetails['user']!['seats'] ?? [];

  Map<String, dynamic> selectedSeat = seats.firstWhere(
    (seat) => seat['mst_seat_id'] == currentSeatId,
    orElse: () => null,
  );

  return selectedSeat;
}
