import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class SSO extends StatefulWidget {
  const SSO({super.key});

  @override
  State<SSO> createState() => _SSOState();
}

class _SSOState extends State<SSO> {
  @override
  String _latestLink = 'Unknown';

  Future<void> initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _latestLink = initialLink;
        // Check if the link matches the expected callback URL "/sso" and take appropriate actions.
        if (initialLink == "m-samagra://kseb.in/sso") {
          // Open your sso.dart class or perform the desired actions.
        }
      }
    } on PlatformException {
      // Handle any exceptions that occur.
    }
  }

  void initState() {
    super.initState();
    initUniLinks();
  }

  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
