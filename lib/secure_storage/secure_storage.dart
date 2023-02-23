// import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  String key = '';

  final _storage = new FlutterSecureStorage();

  SecureStorage({this.key = ''});

  Future getSecureStorageDataByKey(key) async {
// Read value
    var val = await _storage.read(key: key);

    return val;
  }

  Future getSecureAllStorageData(key) async {
// Read value
    var val = await _storage.readAll();

    return val;
  }

  Future getSecureAllStorageDataByKey(key) async {
// Read value
    var val = await _storage.readAll();

    return val;
  }

  Future deleteSecureStorageBykey(key) async {
// Read value
    var val = await _storage.delete(key: key);

    return val;
  }

  Future deleteAlllSecureStorageData() async {
// Read value
    var val = await _storage.deleteAll();

    return val;
  }

  Future writeKeyValuePairToSecureStorage(key, value) async {
// Read value

    var val = await _storage.write(key: key, value: value);

    return val;
  }
}





// Write value
