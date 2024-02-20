import 'dart:convert';
import 'dart:io';

import 'package:android_package_installer/android_package_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheck extends StatefulWidget {
  @override
  _UpdateCheckState createState() => _UpdateCheckState();
}

class _UpdateCheckState extends State<UpdateCheck> {
  bool _needsUpdate = false;
  getLatestVersionFromServer() {}
  String _currentVersion = '1.0.0';
  String _latestVersion =
      '2.5.0'; // Replace with the latest version from the server
  final String apkUrl = 'https://hris.kseb.in/osvtest/tmp/msamagra-8.apk';

  // String ap

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
    _needsUpdateCheck();
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  Future<bool> _needsUpdateCheck() async {
    return Future.value(true);

//implement getLatest version from samagra
    return _currentVersion != _latestVersion;
  }

  Future<void> _downloadAndInstallApk() async {
    Dio dio = Dio();

    try {
      // apkUrl
      Response response = await dio.get(apkUrl,
          options: Options(responseType: ResponseType.bytes));

      final String dir = (await getExternalStorageDirectory())!.path;
      final File file = File('$dir/app1.apk');
      await file.writeAsBytes(response.data as List<int>);

      await launch(apkUrl);

      // debugger(when: true);
      // Use package_installer or url_launcher to launch the installation process
      // For example using package_installer:

      print("file $file");
      int? statusCode = await AndroidPackageInstaller.installApk(
          apkFilePath: '$dir/app1.apk');
      print(file.runtimeType);
      print("status code $statusCode");

      if (statusCode != null) {
        PackageInstallerStatus installationStatus =
            PackageInstallerStatus.byCode(statusCode);
        print(installationStatus.name);
      } // Make sure to include required permissions

      // For url_launcher:
      // Launch the file path (Note: For Android, you need an intent to start the installation)
    } catch (e) {
      print("Error downloading APK: $e");
    }
  }

  void _showUpdateDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

                  _downloadAndInstallApk();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginScreen()),
                  // );
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentVersion.isNotEmpty && _needsUpdate) {
      _showUpdateDialog();
    }
    return LoginScreen();
  }
}
