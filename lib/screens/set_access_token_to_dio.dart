import '../secure_storage/secure_storage.dart';

setAccessTockenToDio(dio) async {
  var _secureStorage = SecureStorage();
  Map accessToken1 =
      await _secureStorage.getSecureAllStorageDataByKey("access_token");

  String accessToken = accessToken1['access_token'];

  dio.options.headers['Authorization'] = 'Bearer $accessToken';
  return dio;
}
