import 'package:dio/dio.dart';

class HttpHelper {
  Dio dio = Dio();

  Future<Response> get(String url) async {
    try {
      return await dio.get(url);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String url, dynamic data) async {
    try {
      return await dio.post(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String url, dynamic data) async {
    try {
      return await dio.put(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String url) async {
    try {
      return await dio.delete(url);
    } catch (e) {
      rethrow;
    }
  }
}
