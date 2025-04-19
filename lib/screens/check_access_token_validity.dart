import 'package:jwt_decode/jwt_decode.dart';

Future<bool> checkAccessTokenValidity(String jwtToken) async {
  if (jwtToken.isEmpty) {
    return false;
  }

  try {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(jwtToken);

    if (decodedToken.containsKey('exp')) {
      double expiryTimeInSeconds = decodedToken['exp'].toDouble();
      double currentTimeInSeconds =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toDouble();

      double remainingSeconds = expiryTimeInSeconds - currentTimeInSeconds;

      return remainingSeconds > 0;
    } else {
      print('Token does not contain expiration time.');
      return false;
    }
  } catch (e) {
    print('Error validating access token: $e');
    return false;
  }
}
