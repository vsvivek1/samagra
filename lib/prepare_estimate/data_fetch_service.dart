import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/configProviderSingleton.dart';

class DataFetchService {
  String baseUrl = ConfigProviderSingleton.instance.liveAccessUrl;
  final Dio _dio = Dio();

  /// Builds API URL based on the type using a switch case
  Future<List<Map<String, dynamic>>> fetchData(String type, dynamic id) async {
    String url;

    baseUrl = "http://192.168.1.215:8000/api";

    switch (type) {
      case 'localBodies':
        url = "$baseUrl/office-local-body/get-map/$id";
        break;
      case 'villages':
        url = "$baseUrl/office-local-body/get-local-body-by-district/$id";
        break;
      case 'assemblies':
        url = "$baseUrl/office-assembly/get-map/$id";
        break;
      default:
        throw Exception("Invalid type: $type");
    }

    try {
      print(url);
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      throw Exception("Error fetching $type data: ${e.toString()}");
    }

    return [];
  }
}
