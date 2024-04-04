import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/common.dart';

import '../screens/login_screen.dart';
import '../screens/set_access_toke_and_api_key.dart';

class VersionController extends StatefulWidget {
  @override
  _VersionControllerState createState() => _VersionControllerState();
}

class _VersionControllerState extends State<VersionController> {
  String versionNumber = '';
  String link = '';
  String remarks = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url =
        "https://ws.kseb.in/resource/api/erp/group1/checklatestVersionForAndroid";
    Response response = await dio.get(url, options: Options(headers: headers));

    debugger(when: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Version Number'),
              onChanged: (value) {
                setState(() {
                  versionNumber = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Link'),
              onChanged: (value) {
                setState(() {
                  link = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Remarks'),
              onChanged: (value) {
                setState(() {
                  remarks = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle submit action here
                print('Version Number: $versionNumber');
                print('Link: $link');
                print('Remarks: $remarks');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
