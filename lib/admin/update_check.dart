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
  final String apkUrl =
      'https://ws.kseb.in/resource/api/erp/group1/api/erp/group1/app_versions';

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
    Dio dio = new Dio();

    var headers = {
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI2IiwianRpIjoiODAxMGMzZTNkMmU4MTJhNjZiZWZiYmI5NjcxZmRmYzM4ZmFjZjI2YWJhMTY2ZTc1YWQxYzY5Y2JjNzdkYjgzM2EyOGQ2MjUzMmVmYjhkYTMiLCJpYXQiOjE3MDgzMzMzNzUsIm5iZiI6MTcwODMzMzM3NSwiZXhwIjoxNzA4MzM2OTc1LCJzdWIiOiIyMTcwMSIsInNjb3BlcyI6W119.RF9kIsVzwMMwapRQb9QvflLsB6xouPZakPmhNi5VktoPEPM0t1eShyzskHQDTg6YC82C5a0-81xrL5SYTMOvCS54kMu-80HwcdXoEHuqF1IN8lEjfqLeMBN6dCFWvllUp22TMgGgYj5JmUIBjyXwz60Pw-ZJhVHKrqrSJd3B7BQKbLgaMS2pHrgWKelLw9tUBlzOulXJQ5_UtLef2c8aHVcobx4XdXGCrTkLSwlGDTbmijRcSX5z1w9fWnlLTGoIu5Yuft2dGwkBIyUof-9dUcLG6gQCXVtdbrJIhg2bJmOQaIdAADRxg1CYZ4xQw9sp7msQcb8BeRvKfpmYx2Ar9Fyib65qfThBD5JrE5dLMhXf5QsbclR-MuD5oOTCQSMXh6v4trE7pXRQwAkmiZAxUkugRJIYe2Gc7sAUWwe3bQVTCM1XTGTwURNVaSRrOwnigjI2HYrr4PhikYXFVfUP7rXls5bkNwLhshAmywd8CBZrHj0XO89gco_FO03Z24H0g7oaP4jL8Dvg7vQoarpOfMFSwAxNJ3-CSUyTgrwYdkFj8AZxdErJQ5oL27grOW6080Udy3nKU56VGvETrNZWbFxPU75wF3zu8zVwTZFU9eGQdJCRDl5nvHBkEVwWcgyR7dnfiPr_uevLj8DFZuJMlbye4pM62sR6GeCgROVY4_g"',
      'Cookie': 'laravel_session=6O2cN4jz3kwzpWd3ecL92Q7eknNmM7fiEVzUr7fG'
    };
// var dio = Dio();
    var response = await dio.request(
      apkUrl,
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }

    // print(a);

    return Future.value(false);
    return true;
    // Compare the current version with the latest version
    //  print("$_currentVersion _currentVersion ${packageInfo.version}");

    return _currentVersion != _latestVersion;
  }

  Future<void> _downloadAndInstallApk() async {
    Dio dio = Dio();

    try {
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

                  // _downloadAndInstallApk();
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
