// ignore: import_of_legacy_library_into_null_safe
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiHelper {
  Dio dio = Dio();
  final storage = new FlutterSecureStorage();

  Future<void> postAndSave(String url, dynamic data) async {
    try {
      final response = await dio.post(url, data: data);
      await storage.write(key: "token", value: response.data['token']);
    } catch (e) {
      rethrow;
    }
  }
}
