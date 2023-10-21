import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String generateCodeChallenge(String codeVerifier) {
  // Calculate the SHA-256 hash of the code verifier
  final codeVerifierBytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(codeVerifierBytes);

  // Encode the digest in base64 URL-safe encoding
  final base64Url = base64UrlEncode(digest.bytes);

  return base64Url;
}

launchSSOUrl() async {
  const CLIENT_ID = "pkce-client3";

  const REDIRECT_URI = "m-samagra://kseb.in/sso";

  const codeVerifier = 'vivek';
  String codeChallenge = generateCodeChallenge(codeVerifier);

  const codeChallengeMethod = 'S256';

  const scope = 'scope=openid%20offline_access%20erp_work';

  String url =
      '''https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/auth?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&code_chalenge=${codeChallenge}&code_challenge_method=${codeChallengeMethod}&scope=${scope}&state=1234zyx''';

  print(url);

  final Uri _url = Uri.parse(url);

  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
