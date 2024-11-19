import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/configProviderSingleton.dart';

class DataFetchService {
  final String baseUrl = ConfigProviderSingleton.instance.liveAccessUrl;
  final Dio _dio = Dio();

  /// Builds API URL based on the type using a switch case
  String _buildApiUrl(String type, int id) {
    switch (type) {
      case "officeDetails":
        return "$baseUrl/api/office-details/get-map/$id";
      case "village":
        return "$baseUrl/api/village/get-map/$id";
      case "district":
        return "$baseUrl/api/district/get-map/$id";
      case "assembly":
        return "$baseUrl/api/assembly/get-map/$id";

      case "localBody":
        return "$baseUrl/api/office-local-body/get-map/$id";
      default:
        throw Exception("Invalid type: $type");
    }
  }

  /// Fetch data for a specific type and ID
  Future<List<Map<String, dynamic>>> fetchData(String type, int id) async {
    try {
      final String fullApiUrl = _buildApiUrl(type, id); // Get URL dynamically
      final response = await _dio.get(fullApiUrl);
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching data for $type with ID $id: ${e.toString()}");
    }
    return [];
  }
}
