import 'dart:convert';
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

  var comments;

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
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";
    Response response = await dio.get(url, options: Options(headers: headers));

    //debugger(when: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Version Controller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Comments'),
              onChanged: (value) {
                setState(() {
                  comments = value;
                });
              },
            ),
            SizedBox(height: 20),
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

                _storeVersion();
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

  void _storeVersion() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";

    /*  Map data = {};
    data['version'] = versionNumber;
    data['url'] = link;
    data['comments'] = comments;
    data['platform'] = 'android';
    data['date'] = new DateTime.now(); */

    var data = FormData.fromMap({
      'platform': 'android',
      'date': new DateTime.now(),
      'version': versionNumber,
      'comments': comments,
      'url': link,
    });

/* var response = await dio.request(
  'http://localhost:8000/api/app_versions/',
  options: Options(
    method: 'POST',
    headers: headers,
  ),
  data: data,
); */

    try {
      Response response =
          await dio.post(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
      }
    } on Exception catch (e) {
      print(e);
      debugger(when: true);
      // TODO
    }
  }

  void _listVersions() {}
  void _deleteVersion() {}
  void _updateVersion() {}
}
