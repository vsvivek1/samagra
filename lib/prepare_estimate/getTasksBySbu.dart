import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String> getTasksBySbu(int sbuId) async {
  const String baseUrl = "localUrl/api";
  final String url = '$baseUrl/tasks/sbu/$sbuId';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final Dio dio = Dio();

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      var data = response.data;
      String jsonData = jsonEncode(data);

      // Store tasks and timestamp in local storage
      await secureStorage.write(key: 'mst_tasks_sbu', value: jsonData);
      await secureStorage.write(key: 'mst_tasks_sbu_timestamp', value: DateTime.now().toIso8601String());

      print('Tasks fetched and stored successfully.');
      return jsonData; // Return fetched data
    } else {
      print('Failed to load tasks. Status code: ${response.statusCode}');
      return 'Error fetching tasks';
    }
  } catch (e) {
    print('Error fetching tasks: $e');
    return 'Error fetching tasks';
  }
}
