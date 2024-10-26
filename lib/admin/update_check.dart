import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_package_installer/android_package_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:samagra/admin/update_dialog.dart';
import 'package:samagra/common.dart';
import 'package:samagra/custom_drawer/home_drawer.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:samagra/screens/server_error.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/screens/sso.dart';
// IMPORT PACKAGE

//import 'package:package_installer/package_installer.dart';
String apkUrl = '';

Future<void> installUpdate(String filePath) async {
  debugger(when: true);
  int? statusCode =
      await AndroidPackageInstaller.installApk(apkFilePath: filePath);
  var code;
}

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

  String update = 'Update';
/*   ReceivePort _port = ReceivePort(); */

  // String ap

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    _getPackageInfo();

    _initializeState();
    //
/* 
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      //  DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];

      //debugger(when: true);
      setState(() {});
    }); */
    super.initState();
  }

  Future<void> _initializeState() async {
    await _getPackageInfo();

    /* print("curent version $localVersion");
    print("print server version $serverVersion"); */
    //
    //await _listVersions();
    // print("curent version $localVersion");
    // print("print server version $serverVersion");
    //

    //
    // await _needsUpdateCheck();

    /*  print("curent version $localVersion");
    print("print server version $serverVersion");
    
     */
  }

  Future _listVersions() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();

    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

    // String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";

    String url = "${config.liveServiceUrl}app_versions";

    String PlatForm = Platform.isAndroid ? 'Android' : 'IOS';

    try {
      Response response =
          await dio.get(url, options: Options(headers: headers));

      //
      //String serverVersion = '';`

      if (response.statusCode == 200) {
        if (response.data != null) {
          Map version = response.data.firstWhere((d) =>
              d['platform'].toString().toUpperCase() == PlatForm.toUpperCase());
          //
          serverVersion = version['version'].toString().toUpperCase();
          //

          if (config.deploymentMode.contains("UAT")) {
            apkUrl = version['url'] ??
                'https://ws.kseb.in/mstore/samagra/msamagraUAT.apk';
          } else {
            apkUrl = version['url'] ??
                'https://ws.kseb.in/mstore/samagra/msamagra.apk';
          }

          //

          //
        }

        //
        Fluttertoast.showToast(
            msg: 'Current server Version :' +
                    response.data[0]['version'] +
                    '\n Current local Version :' +
                    _currentVersion ??
                '-1',
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

    _currentVersion = packageInfo.version;
    localVersion = packageInfo.version;
    /*  setState(() {
 
    }); */
  }

  Future<bool> _needsUpdateCheck() async {
    if (localVersion != serverVersion) {
      _needsUpdate = true;
      /*  setState(() {
       
      }) */
      ;
    } else {
      return false;
    }
    return Future.value(true);

//implement getLatest version from samagra
    return _currentVersion != _latestVersion;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _listVersions(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data is DioException) {
          //debugger(when: true);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(actions: [
                TextButton(
                    onPressed: () => pleaseLogin(), child: Text('Please login'))
              ], content: Text('Server Error . Please try after some time '));
            },
          );

          Fluttertoast.showToast(msg: "Server Error Please Re login");
          String msg1 = "Server Error Please Re login";
          return ServerError(msg1);

          /*  Navigator.push(context, MaterialPageRoute(builder: ((context) {
            return LoginScreen();
          }))); */
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the Future is still loading
          return SpinKitDualRing(
              color: Colors.blue); // Or any other loading indicator
        } else if (snapshot.hasError) {
          // If there's an error
          return Text('Error: ${snapshot.error}');
        } else {
          // If the Future has resolved successfully
          // You can access the result using snapshot.data
          /*   if (snapshot.data is DioException) {
            return Center(child: Text('Dio Exception'));
          } */

          serverVersion = snapshot.data;

          if (serverVersion == localVersion) {
            _needsUpdate = false;
          } else {
            _needsUpdate = true;
          }

          //

          //* implement your logic to determine if update is needed */;
          if (_needsUpdate) {
            return UpdateDialog(
              localVersion: localVersion,
              serverVersion: serverVersion,
              apkUrl: apkUrl, // Pass the APK URL if needed
            );
          } else {
            return NavigationHomeScreen();
          }
        }
      },
    );
  }

  pleaseLogin() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SSO(); // Return the SSO screen with parameters if needed
      },
    ));
  }
}
