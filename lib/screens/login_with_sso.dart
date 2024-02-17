import 'package:samagra/screens/launch_sso_url.dart';
import 'package:samagra/screens/login_screen.dart';

loginUsingSso(context, _ssoLoginLoading, setLoginState, empcode) {
  // initUniLinks();
  setLoginState();

  launchSSOUrl(codeVerifier, codeChallenge, empcode);
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => SSOLogin()),
  // );
}
