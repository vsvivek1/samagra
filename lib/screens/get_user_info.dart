import 'package:dio/dio.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

Future getUserInfo(String accessToken, _ssoLoginLoading) async {
  Dio dio = Dio();

  EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
  String url = '${config.liveServiceUrlLogin}/auth/getUserInfo';

  String apiKey = '${config.apiKey}';

  try {
    // EnvironmentConfig config = EnvironmentConfig.fromEnvFile();
    // Set up headers with the access token and API key

    setDioAccessokenAndApiKey(
        dio, accessToken, config); // Replace with your actual API key

    Response response = await dio.post(url);
    // debugger(when: true);

    return response.data;

    // You might return null or handle this differently based on your use case

    // You might return null or handle this differently based on your use case
    // return response.data;
  } catch (e) {
    return e;

    throw Exception('Error: $e');
  }
}
