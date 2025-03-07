import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Super function to check if data is older than 3 days and refresh if needed
Future<String> checkAndRefreshData({
  required String storageKey,
  required String timestampKey,
  required Future<String> Function() refreshFunction,
}) async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  try {
    // Read stored data and timestamp
    String? storedData = await secureStorage.read(key: storageKey);
    String? storedTimestamp = await secureStorage.read(key: timestampKey);

    if (storedData != null && storedTimestamp != null) {
      DateTime storedTime = DateTime.parse(storedTimestamp);
      DateTime now = DateTime.now();

      // Check if data is fresh (less than 3 days old)
      if (now.difference(storedTime).inDays < 3) {
        print('$storageKey is available in storage and up to date.');
        return storedData; // Return stored data to main function
      }
    }

    // If no valid data or older than 3 days, refresh it
    print('Refreshing $storageKey data...');
    return await refreshFunction(); // Fetch new data and return it
  } catch (e) {
    print('Error checking $storageKey: $e');
    return 'Error fetching data';
  }
}
