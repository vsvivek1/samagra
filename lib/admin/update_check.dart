import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_package_installer/android_package_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:samagra/common.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UpdateCheck extends StatefulWidget {
  @override
  _UpdateCheckState createState() => _UpdateCheckState();
}

class _UpdateCheckState extends State<UpdateCheck> {
  bool _needsUpdate = false;
  getLatestVersionFromServer() {}
  String _currentVersion = '';

  String localVersion = '-1';
  String serverVersion = '-1';
  String _latestVersion =
      '2.5.0'; // Replace with the latest version from the server
  final String apkUrl = 'https://hris.kseb.in/osvtest/tmp/msamagra-8.apk';

  // String ap

  @override
  void initState() {
    super.initState();
    _getPackageInfo();

    _initializeState();
  }

  Future<void> _initializeState() async {
    await _getPackageInfo();
    await _listVersions();
    _needsUpdateCheck();
  }

  Future _listVersions() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";

    String PlatForm = Platform.isAndroid ? 'Android' : 'IOS';

    try {
      Response response =
          await dio.get(url, options: Options(headers: headers));
      //String serverVersion = '';

      if (response.statusCode == 200) {
        if (response.data != null) {
          Map version = response.data.firstWhere((d) =>
              d['platform'].toString().toUpperCase() == PlatForm.toUpperCase());

          serverVersion = version['version'].toString().toUpperCase();

          // debugger(when: true);
        }

        //debugger(when: true);
        Fluttertoast.showToast(
            msg: 'Current Version :' + response.data[0]['version'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        // print(json.encode(response.data));

        return serverVersion;

        // return response.data;
      } else {
        return response.statusMessage;
      }
    } on Exception catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Dio Error: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      return e;

      // TODO
    }
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
      localVersion = packageInfo.version;
    });
  }

  Future<bool> _needsUpdateCheck() async {
    if (localVersion != serverVersion) {
      setState(() {
        //_needsUpdate = true;
      });
    }
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
          return displayUpdateWidget();
        },
      );
    });
  }

  AlertDialog displayUpdateWidget() {
    return AlertDialog(
      title: Text('Update Available'),
      content: SizedBox(
        height: 100,
        child: Column(
          children: [
            Text(
                'A new version of M-samagra is available. Please update to the latest version.'),
            Text('Current Version $localVersion'),
            Text('New Version Available $serverVersion'),
          ],
        ),
      ),
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
  }

  @override
  Widget build(BuildContext context) {
    if (_currentVersion.isNotEmpty && _needsUpdate) {
      //debugger(when: true);
      return displayUpdateWidget();
      //_showUpdateDialog();
    } else {
      // debugger(when: true);
      return NavigationHomeScreen();
    }

    //return LoginScreen();
  }
}
