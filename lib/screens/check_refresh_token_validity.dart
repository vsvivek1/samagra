import 'package:jwt_decode/jwt_decode.dart';
import 'package:samagra/check_jwt_expiry.dart';

Future<bool> checkRefreshTokenValidity() async {
  try {
    String refreshToken = await getRefreshTokenFromStorage();

    if (refreshToken.isEmpty) {
      print('Refresh token is empty.');
      return false;
    }

    Map<String, dynamic> decodedToken = Jwt.parseJwt(refreshToken);

    if (decodedToken.containsKey('exp')) {
      double expiryTimeInSeconds = decodedToken['exp'].toDouble();
      double currentTimeInSeconds =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toDouble();

      double remainingSeconds = expiryTimeInSeconds - currentTimeInSeconds;

      return remainingSeconds > 0;
    } else {
      print('Refresh token does not contain expiration time.');
      return false;
    }
  } catch (e) {
    print('Error checking refresh token validity: $e');
    return false;
  }
}
