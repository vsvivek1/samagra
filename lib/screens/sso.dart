
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
      final initialUri = await getInitialUri();

      // debugger(when: true);
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
