import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/check_jwt_expiry.dart';

final Dio _dio = Dio();
final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

/// Notifies about expired token and updates it using the refresh token.
Future<void> expiredTokenNotifierAndUpdater() async {
  try {
    // Show a toast message for login expiration
    Fluttertoast.showToast(
      msg: "Login expired, retrying automatically...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // Adjust position as needed
      timeInSecForIosWeb: 1,
    );

    String refreshToken = await getRefreshTokenFromStorage();
    await refreshAccessToken(refreshToken);

    Fluttertoast.showToast(
      msg: "Now try again",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // Adjust position as needed
      timeInSecForIosWeb: 1,
    );
  } catch (e) {
    // Show a toast message for failure
    Fluttertoast.showToast(
      msg: "Token refresh failed: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
    );
    rethrow; // Re-throw the error for further handling if needed
  }
}
