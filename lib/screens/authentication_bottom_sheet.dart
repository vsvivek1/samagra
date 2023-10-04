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
      print(_auth);
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
      setState(() {
        _authenticated = authenticated;
      });
    } on PlatformException catch (e) {
      print(e);
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
            "Place your finger on FingerPrint for Loggin in ",
            style: TextStyle(
                color: Color.fromARGB(92, 10, 161, 226), fontSize: 15),
          ),
          SizedBox(
            height: 20,
          ),
          IconButton(
            iconSize: 60,
            icon: Icon(Icons.fingerprint),
            onPressed: () {
              _authenticate();
            },
          ),
          if (_authenticated) // show the login button if authenticated
            ElevatedButton(
              child: Text('Login'),
              onPressed: () {
                print('pressed');
                // handle login action here
              },
            ),
        ],
      ),
    );
  }
}
