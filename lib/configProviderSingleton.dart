import 'package:samagra/environmental_config.dart';

class ConfigProviderSingleton {
  static final ConfigProviderSingleton _instance =
      ConfigProviderSingleton._internal();

  late final EnvironmentConfig config;

  ConfigProviderSingleton._internal();

  static ConfigProviderSingleton get instance => _instance;

  /// Initialize the configuration (called once in the app lifecycle).
  Future<void> initialize() async {
    config = await EnvironmentConfig.fromEnvFile();
  }

  /// Get the liveAccessUrl (shortcut for convenience).
  String get liveAccessUrl => config.liveAccessUrl;
}
