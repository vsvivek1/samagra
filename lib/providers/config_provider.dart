import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samagra/environmental_config.dart';

class ConfigProvider extends ChangeNotifier {
  late EnvironmentConfig _config;

  EnvironmentConfig get config => _config;

  Future<void> loadConfig() async {
    try {
      await dotenv.load(fileName: ".env");
      _config = await EnvironmentConfig.fromEnvFile();
      notifyListeners(); // Notify listeners about the new config
    } catch (e) {
      debugPrint("Error loading .env file: $e");
      // Handle the error appropriately (throw/recover)
    }
  }
}
