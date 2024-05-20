import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:percent_indicator/percent_indicator.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if you want to use url_launcher

class UpdateDialog extends StatefulWidget {
  final String localVersion;
  final String serverVersion;
  final String apkUrl;

  UpdateDialog({
    required this.localVersion,
    required this.serverVersion,
    required this.apkUrl, // Add this if you want to pass the APK URL
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  String update = '';
  late OtaEvent currentEvent;

  bool _startedDownloading = false;

  int _percentageComplete = 0;
  // You can optionally add this method to handle opening a URL
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
          // print("event is ${event.status} and ${event.value}");

          String status = event.status.toString().split('.')[1];

          setState(() {
            _percentageComplete = int.parse(event.value ?? '0');
            update = '${status} ${event.value} %';
          });

          //  setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }

    return;
    /////////////////

    //debugger(when: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Available'),
      content: SizedBox(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'A new version of M-samagra is available.\n\n Please update to the latest version.'),
            Text('\nCurrent Version on this Device: ${widget.localVersion}'),
            Text(
                '\nNew Version Available for this Device: ${widget.serverVersion}'),
          ],
        ),
      ),
      actions: <Widget>[
        if (!_startedDownloading)
          TextButton(
            onPressed: () {
              // Add logic to redirect users to the app store for update
              // For example: _launchURL('URL_TO_APP_STORE');
              // You can also call a method to download and install the APK if needed

              // Uncomment this if you are using the _downloadAndInstallApk method
              // setState(() {
              //   update = 'Updating ....';
              // });

              setState(() {
                _startedDownloading = true;
              });
              _downloadAndInstallApk(widget.apkUrl);

              // Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Update"),
          ),
        if (_startedDownloading)
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width * .6,
            animation: true,
            lineHeight: 20.0,
            animationDuration: 1000,
            percent: _percentageComplete / 100,
            center: Text("${_percentageComplete.toString()}%"),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Colors.greenAccent,
          )
      ],
    );
  }
}
