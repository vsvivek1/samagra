import 'dart:convert';
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
import 'package:samagra/common.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
// IMPORT PACKAGE
import 'package:ota_update/ota_update.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

//import 'package:package_installer/package_installer.dart';
String apkUrl = '';

Future<void> installUpdate(String filePath) async {
  debugger(when: true);
  int? statusCode =
      await AndroidPackageInstaller.installApk(apkFilePath: filePath);
  var code;
  if (code != null) {
    PackageInstallerStatus installationStatus =
        PackageInstallerStatus.byCode(statusCode!);
    print(installationStatus.name);
  }
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
  ReceivePort _port = ReceivePort();

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

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      //  DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];

      //debugger(when: true);
      setState(() {});
    });
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
    //
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";

    String PlatForm = Platform.isAndroid ? 'Android' : 'IOS';

    try {
      Response response =
          await dio.get(url, options: Options(headers: headers));

      //
      //String serverVersion = '';

      if (response.statusCode == 200) {
        if (response.data != null) {
          Map version = response.data.firstWhere((d) =>
              d['platform'].toString().toUpperCase() == PlatForm.toUpperCase());
          //
          serverVersion = version['version'].toString().toUpperCase();
          //
          apkUrl = version['url'] ??
              'https://ws.kseb.in/mstore/samagra/msamagra.apk';
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

  Future<void> _downloadAndInstallApk(String apkUrl) async {
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
        apkUrl,
        // OPTIONAL
        destinationFilename: 'msamagra.apk',
        //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        /*  sha256checksum:
            "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478", */
      )
          .listen(
        (OtaEvent event) {
          OtaEvent currentEvent;
          print("event is ${event.status} and ${event.value}");

          if (int.parse(event.value as String) % 5 == 0) {
            update = '${event.status} and ${event.value}';
            setState(() {});
          }

          /*  setState(() {
           
          }); */
          //  setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }

    return;
    /////////////////
    WidgetsFlutterBinding.ensureInitialized();

    //debugger(when: true);
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

  Builder displayUpdateWidget() {
    return Builder(builder: (context) {
      return AlertDialog(
        title: Text('Update Available'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Text(
                  'A new version of M-samagra is available.\n\n Please update to the latest version.'),
              Text('\nCurrent Version in this Device: $localVersion'),
              Text('\nNew Version Available for this device: $serverVersion'),
            ],
          ),
        ),
        actions: <Widget>[
          Builder(builder: (context) {
            return TextButton(
              onPressed: () {
                // Add logic to redirect users to the app store for update
                // For example: launch('URL_TO_APP_STORE');

                setState(() {
                  update = 'Updating ....';
                });
                _downloadAndInstallApk(apkUrl);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => LoginScreen()),
                // );
              },
              child: Text("$update"),
            );
          }),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _listVersions(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data is DioException) {
          Fluttertoast.showToast(msg: "Server Error Please Re login");
          Navigator.push(context, MaterialPageRoute(builder: ((context) {
            return LoginScreen();
          })));
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
            return displayUpdateWidget();
          } else {
            return NavigationHomeScreen();
          }
        }
      },
    );
  }
}
