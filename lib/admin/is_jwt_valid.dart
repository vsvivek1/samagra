import 'package:jwt_decoder/jwt_decoder.dart';

bool isAccessTokenValid(String accessToken) {
  try {
    // Decode the access token
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    // Check if the token has expired (optional)
    bool isTokenExpired = JwtDecoder.isExpired(decodedToken['exp']);

    // You can also check other claims if needed

    // Return true if the token is valid and not expired
    return !isTokenExpired;
  } catch (e) {
    // Handle any errors (e.g., invalid token format)
    print('Error decoding or validating access token: $e');
    return false;
  }
}
