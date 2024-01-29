import 'package:samagra/secure_storage/secure_storage.dart';
import 'dart:convert';

var _secureStorage = SecureStorage();

bool isJson(String str) {
  try {
    jsonDecode(str);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> _getUserLoginDetails() async {
  var _loginDetails1 =
      await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

  return _loginDetails1["loginDetails"]; //.toString();
}

void p(msg) {
  debugPrint('-----------------------');

  debugPrint(msg);
  debugPrint('-----------------------');
}
