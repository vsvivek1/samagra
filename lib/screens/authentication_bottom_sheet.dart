import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationBottomSheet extends StatefulWidget {
  const AuthenticationBottomSheet({super.key});

  @override
  State<AuthenticationBottomSheet> createState() =>
      _AuthenticationBottomSheetState();
}

class _AuthenticationBottomSheetState extends State<AuthenticationBottomSheet> {
  bool _authenticated = false;
  final _auth = LocalAuthentication();

  // function to authenticate with biometrics
  Future<void> _authenticate() async {
    try {
      debugPrint(_auth);
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerdebugPrint to authenticate',
      );
      setState(() {
        _authenticated = authenticated;
      });
    } on PlatformException catch (e) {
      debugPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // add your other content here

          Text(
            "Place your finger on FingerdebugPrint for Loggin in ",
            style: TextStyle(
                color: Color.fromARGB(92, 10, 161, 226), fontSize: 15),
          ),
          SizedBox(
            height: 20,
          ),
          IconButton(
            iconSize: 60,
            icon: Icon(Icons.fingerdebugPrint),
            onPressed: () {
              _authenticate();
            },
          ),
          if (_authenticated) // show the login button if authenticated
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                debugPrint('pressed');
                // handle login action here
              },
            ),
        ],
      ),
    );
  }
}
