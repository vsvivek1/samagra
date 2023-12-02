import 'dart:developer';

import 'package:samagra/screens/generate_random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateCodeChallenge(String codeVerifier) {
  codeVerifier =
      "4fjs9aP0kL3wTcR6dFgHyb7tMzS1lUxXoQvNpA2iErD5uG8WJhKqZIeCnVYmO";
  // Calculate the SHA-256 hash of the code verifier
  final codeVerifierBytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(codeVerifierBytes);

  // Encode the digest in base64 URL-safe encoding
  final base64Url = base64UrlEncode(digest.bytes);

  return base64Url;
}

String base64URL(String input) {
  String encoded = base64Url.encode(utf8.encode(input));
  return encoded.replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
}

launchSSOUrl(codeVerifier, codeChallenge) async {
  const CLIENT_ID = "pkce-client3";

  // const REDIRECT_URI = "m-samagra://kseb.in/sso";
  // const REDIRECT_URI = "m-samagra%3A%2F%2Fkseb.in%2Fsso";
  // const REDIRECT_URI = "m-samagra%3A%2F%2Fkseb.in%2Fsso";
  const REDIRECT_URI = "http://kseb.in/ksebhome";
  // const REDIRECT_URI = "https://kseb.in/ksebhome";

  // const codeVerifier = 'vivek';

  // String codeChallenge = generateCodeChallenge(codeVerifier);

  const codeChallengeMethod = 'S256';

  const scope = 'scope=openid%20offline_access%20erp_work';

  String url2 =
      '''https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/auth?response_type=code&client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&code_challenge=$codeChallenge&code_challenge_method=$codeChallengeMethod&scope=$scope&state=1234zyx''';

  String url =
      // "https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/auth?response_type=code&client_id=pkce-client3&redirect_uri=m-samagra%3A%2F%2Fkseb.in%2Fsso&code_challenge=${codeChallenge}&code_challenge_method=S256&scope=openid%20offline_access%20erp_work";
      "https://hris.kseb.in/ssotest/auth/realms/kseb/protocol/openid-connect/auth?response_type=code&client_id=pkce-client3&redirect_uri=m-samagra%3A%2F%2Fkseb.in%2Fsso&code_challenge=${codeChallenge}&code_challenge_method=S256&scope=openid%20offline_access%20erp_work";
  print(url);

  final Uri _url = Uri.parse(url);

  // debugger(when: true);

  // print(url);
  // launchUrl(url, mode: LaunchMode.externalApplication);
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $_url');
  }
}
