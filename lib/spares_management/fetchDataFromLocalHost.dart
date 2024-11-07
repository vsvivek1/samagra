import 'package:dio/dio.dart';

Future<void> fetchData() async {
  try {
    // Adjust the URL based on your Laravel API endpoint
    //String apiUrl = 'http://192.168.100.112:8000/api/test';
    //String apiUrl = 'http://192.168.100.101/api/test';

    String apiUrl = 'http://192.168.100.101/api/test';
    // 192.168.100.101

    final Dio _dio = Dio();
    Response response = await _dio.get(apiUrl);

    // Print response to console
    print('Response: ${response.data}');
  } catch (e) {
    // Handle error
    print('Error: $e');
  }
}
