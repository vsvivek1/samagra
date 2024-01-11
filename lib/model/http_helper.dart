import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/environmental_config.dart';

Dio dio = Dio();

class HttpHelper {
  Future<Response> get(String url) async {
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    try {
      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
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
