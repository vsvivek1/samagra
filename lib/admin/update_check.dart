import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

void main() {
  runApp(MyApp());
}

class UpdateCheck extends StatefulWidget {
  @override
  _UpdateCheckState createState() => _UpdateCheckState();
}

class _UpdateCheckState extends State<UpdateCheck> {
  String _currentVersion = '';
  String _latestVersion =
      '1.0.0'; // Replace with the latest version from the server

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  bool _needsUpdate() {
    // Compare the current version with the latest version
    return _currentVersion != _latestVersion;
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Available'),
          content: Text(
              'A new version of M-samagra is available. Please update to the latest version.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Add logic to redirect users to the app store for update
                // For example: launch('URL_TO_APP_STORE');
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentVersion.isNotEmpty && _needsUpdate()) {
      _showUpdateDialog();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Check'),
      ),
      body: Center(
        child: Text('Current Version: $_currentVersion'),
      ),
    );
  }
}
