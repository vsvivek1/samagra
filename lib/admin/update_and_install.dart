import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'package:android_package_installer/android_package_installer.dart';

class UpdateAndInstall extends StatelessWidget {
  final String apkUrl =
      'https://drive.google.com/file/d/1r5mNTr5_Z_ie0JckYpxDgI0UEFoWCQfF/view?usp=sharing'; // Replace with your server URL

  Future<void> _downloadAndInstallApk() async {
    Dio dio = Dio();

    try {
      Response response = await dio.get(apkUrl,
          options: Options(responseType: ResponseType.bytes));

      final String dir = (await getExternalStorageDirectory())!.path;
      final File file = File('$dir/app.apk');
      await file.writeAsBytes(response.data as List<int>);

      debugger(when: true);
      // Use package_installer or url_launcher to launch the installation process
      // For example using package_installer:
      // int? statusCode =
      //     await AndroidPackageInstaller.installApk(apkFilePath: '$dir/app.apk');
      // if (statusCode != null) {
      //   PackageInstallerStatus installationStatus =
      //       PackageInstallerStatus.byCode(statusCode);
      //   print(installationStatus.name);

      // } // Make sure to include required permissions

      // For url_launcher:
      // Launch the file path (Note: For Android, you need an intent to start the installation)
    } catch (e) {
      print("Error downloading APK: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update and Install'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _downloadAndInstallApk,
          child: Text('Download and Install Update'),
        ),
      ),
    );
  }
}
