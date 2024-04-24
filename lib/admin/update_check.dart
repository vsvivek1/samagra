import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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

import 'package:flutter_downloader/flutter_downloader.dart';
//import 'package:package_installer/package_installer.dart';

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
  String apkUrl = '';
  String update = 'Update';

  // String ap

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    _getPackageInfo();

    _initializeState();
    //debugger(when: true);

    super.initState();
  }

  Future<void> _initializeState() async {
    await _getPackageInfo();

    /* print("curent version $localVersion");
    print("print server version $serverVersion"); */
    // debugger(when: true);
    //await _listVersions();
    // print("curent version $localVersion");
    // print("print server version $serverVersion");
    // debugger(when: true);

    // debugger(when: true);
    // await _needsUpdateCheck();

    /*  print("curent version $localVersion");
    print("print server version $serverVersion");
    debugger(when: true);
    debugger(when: true); */
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

      //debugger(when: true);
      //String serverVersion = '';

      if (response.statusCode == 200) {
        if (response.data != null) {
          Map version = response.data.firstWhere((d) =>
              d['platform'].toString().toUpperCase() == PlatForm.toUpperCase());

          serverVersion = version['version'].toString().toUpperCase();
          apkUrl = version['url'];

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
    }
    return Future.value(true);

//implement getLatest version from samagra
    return _currentVersion != _latestVersion;
  }

  Future<void> _downloadAndInstallApk() async {
    Dio dio = Dio();

    try {
      // Fetch the APK file
      // await FlutterDownloader.initialize();
      /* final String dir = (await getExternalStorageDirectory())!.path;

      final File file = File('$dir/msamagra.apk'); */

      /*  final taskId = await FlutterDownloader.enqueue(
        url: apkUrl,
        savedDir: dir,
        fileName: 'msamagra.apk', // Customize the filename if needed
        showNotification: true,
        openFileFromNotification: true,
      );
 */

      // debugger(when: true);
      /* FlutterDownloader.registerCallback((id, status, progress) {
        if (status == DownloadTaskStatus.complete) {
          print('ok');
          //installDownloadedApk(id);
        }
      }); */

      Uri apkUri1 = Uri.parse(apkUrl);
      launchUrl(apkUri1);

      return;

      Response response = await dio.get(apkUrl,
          options: Options(responseType: ResponseType.bytes));

      // Save the APK file to external storage
      final String dir = (await getExternalStorageDirectory())!.path;
      final File file = File('$dir/app1.apk');
      await file.writeAsBytes(response.data as List<int>);

      /* AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.INSTALL_PACKAGE',
        data: file.path,
        type: 'application/vnd.android.package-archive',
      );
      await intent.launch(); */

      // Install the APK file
      Uri apkUri = file.uri;

      launchUrl(apkUri);
      /*  int? statusCode = await AndroidPackageInstaller.installApk(
          apkFilePath: apkUri.toString()); */

      /* print("tgis is status code $statusCode");
      // Handle installation status
      if (statusCode != null) {
        PackageInstallerStatus installationStatus =
            PackageInstallerStatus.byCode(statusCode);
        print(installationStatus.name);

        print('reached here ${apkUri.toString()}');

        print(" status is $installationStatus");
      } */
    } catch (e) {
      print("Error downloading and installing APK: $e");
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
        Builder(builder: (context) {
          return TextButton(
            onPressed: () {
              // Add logic to redirect users to the app store for update
              // For example: launch('URL_TO_APP_STORE');

              setState(() {
                update = 'Updating ....';
              });
              _downloadAndInstallApk();
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _listVersions(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data is DioException) {
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

          //debugger(when: true);

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
