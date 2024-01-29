import 'package:dio/dio.dart';
import 'package:samagra/environmental_config.dart';

class MyAPI {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(
      String email, String password, String showPhoto) async {
    final Map<String, String> data = {
      "email": email,
      "password": password,
      "show_photo": showPhoto
    };

    try {
      EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
      final String _url = "${config.liveServiceUrl}login";
      final Response response = await _dio.post(_url, data: data);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint(e.response);

        // debugPrint(e.response.headers);
        // debugPrint(e.response.request);
      } else {
        // debugPrint(e.request);
        debugPrint(e.message);
      }
      throw e;
    }
  }
}
