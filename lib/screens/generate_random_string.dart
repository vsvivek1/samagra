import 'dart:convert';
// import 'dart:js_interop';
import 'dart:math';

String generateRandomString() {
  var random = Random.secure();
  var bytes = List<int>.generate(32, (index) => random.nextInt(256));

  var a = 'TMHrgQx-8RLC_zzlLO2p441cf9UtuNL12GWJMEmEAsk';
  return a;
}

String base64URL(String input) {
  String encoded = base64Url.encode(utf8.encode(input));
  return encoded.replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
}
