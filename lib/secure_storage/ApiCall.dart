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
        print(e.response);

        // print(e.response.headers);
        // print(e.response.request);
      } else {
        // print(e.request);
        print(e.message);
      }
      throw e;
    }
  }
}
