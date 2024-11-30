import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/configProviderSingleton.dart';
import 'dart:io';

Future<String> getCurrentIp() async {
  try {
    // Fetch network interfaces
    List<NetworkInterface> interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      // Check for IPv4 addresses
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address; // Return the first found IPv4 address
        }
      }
    }
  } catch (e) {
    print('Failed to get IP address: $e');
  }
  return '127.0.0.1'; // Default to localhost if no IP is found
}

class DataFetchService {
  String baseUrl = ConfigProviderSingleton.instance.liveAccessUrl;
  final Dio _dio = Dio();

  /// Builds API URL based on the type using a switch case
  Future<List<Map<String, dynamic>>> fetchData(String type, dynamic id) async {
    String url;

    baseUrl = "http://192.168.1.100:8000/api"; //kfon
    print("Base URL: $baseUrl");

    // debugger(when: true);

    //baseUrl = "http://192.168.1.215:8000/api";

    switch (type) {
      case 'localBodies':
        url = "$baseUrl/office-local-body/get-map/$id";
        break;
      case 'villages':
        url = "$baseUrl/office-village/get-map/$id";
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
