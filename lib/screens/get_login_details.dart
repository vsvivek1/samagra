import 'dart:convert';

import '../secure_storage/secure_storage.dart';

getLoginDetails() async {
  final storage = SecureStorage();

  final loginDetails1 =
      await storage.getSecureAllStorageDataByKey('loginDetails');
  final loginDetails = loginDetails1['loginDetails'];

  // debugPrint("LOGIN DETAILS $loginDetails");
  return loginDetails;
}

Map getCurrentSeatDetails(loginDeatails1) {
  if (loginDeatails1 == null) {
    return {};
  }
  Map loginDetails = json.decode(loginDeatails1);

  int currentSeatId = loginDetails['user']!['current_seat_id'] ?? -1;

  var seats = loginDetails['user']!['seats'] ?? [];

  Map<String, dynamic> selectedSeat = seats.firstWhere(
    (seat) => seat['mst_seat_id'] == currentSeatId,
    orElse: () => null,
  );

  return selectedSeat;
}

getSeatDetails() async {
  final storage = SecureStorage();

  final loginDetails1 =
      await storage.getSecureAllStorageDataByKey('loginDetails');
  final loginDetails = loginDetails1['loginDetails'];

  // debugPrint(loginDetails);

  return getCurrentSeatDetails(loginDetails);
  // return loginDetails;
}

getUserId() async {
  final storage = SecureStorage();

  final loginDetails1 =
      await storage.getSecureAllStorageDataByKey('loginDetails');
  final loginDetails = jsonDecode(loginDetails1['loginDetails']);

  String userId = loginDetails['user']['id'].toString();

  return userId;
}

getOfficeId() async {
  var currentSeatDetails = await getSeatDetails();
  final officeId = currentSeatDetails['office_id'];
  return officeId.toString();
}

getUserRoleId() async {
  var currentSeatDetails = await getSeatDetails();
  final officeId = currentSeatDetails['role_id'];
  return officeId.toString();
}

getSeatId() async {
  var currentSeatDetails = await getSeatDetails();
  final seatId = await currentSeatDetails['mst_seat_id'];
  return seatId.toString();
}
