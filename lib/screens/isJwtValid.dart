import 'package:jwt_decoder/jwt_decoder.dart';

bool isJwtTokenValid(String token) {
  try {
    // Check if token is expired
    final decodedToken = JwtDecoder.decode(token);
    if (decodedToken['exp'] != null) {
      final expirationDate =
          DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      if (expirationDate.isBefore(DateTime.now())) {
        return false; // Token is expired
      }
    }

    // Additional checks can be performed here, such as verifying the issuer, audience, etc.

    return true; // Token is valid
  } catch (e) {
    // Token is invalid or malformed

    print('jwt validity check error');
    return false;
  }
}
