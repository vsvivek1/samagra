import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:samagra/admin/CurrentVersionDisplayWidget.dart';
import 'package:samagra/admin/version_input.dart';
import 'package:samagra/coming_soon.dart';
import 'package:samagra/common.dart';
import 'package:samagra/common_styles.dart';

import '../screens/login_screen.dart';
import '../screens/set_access_toke_and_api_key.dart';

class VersionController extends StatefulWidget {
  @override
  _VersionControllerState createState() => _VersionControllerState();
}

class _VersionControllerState extends State<VersionController>
    with SingleTickerProviderStateMixin {
  String versionNumber = '';
  String link = '';
  String remarks = '';

  var comments;

  late TabController _tabController;

  late TextEditingController linkFeildController = TextEditingController(
      text: "https://ws.kseb.in/mstore/samagra/msamagra.apk");
  //TabController(length: 4, vsync: AnimatedListState());

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();

    // _listVersions();
    //fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the TabController
    super.dispose();
  }

  fetchData() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";
    try {
      Response response =
          await dio.get(url, options: Options(headers: headers));
    } on Exception catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // TODO
    }

    //debugger(when: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Version Controller'),
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.grey[200],
            indicatorColor: Colors.grey[100],
            isScrollable: true,
            labelColor: Colors.grey,
            tabs: [
              Tab(text: 'Versions'),
              Tab(text: 'Add new Version'),
              Tab(text: 'Tab 3'),
              Tab(text: 'Tab 4'),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          //CurrentVersionDisplayWidget(),

          SizedBox(
              width: 200,
              height: 100,
              child: CurrentVersionDisplayWidget(config: config)),
          //ComingSoon(),
          SizedBox(width: 200, height: 100, child: addNewVersion()),
          ComingSoon(),
          ComingSoon(),
          /*  ComingSoon(),
          ComingSoon() */
        ]),
      ),
    );
  }

  Padding addNewVersion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*   TextField(
              decoration: InputDecoration(labelText: 'Comments'),
              onChanged: (value) {
                setState(() {
                  comments = value;
                });
              },
            ), */
            SizedBox(height: 20),
            VersionInput(
              onChanged: (version) {
                setState(() {
                  versionNumber = version;
                });
              },
            ),
            /*  TextField(
              decoration: InputDecoration(labelText: 'Version Number'),
              onChanged: (value) {
                setState(() {
                  versionNumber = value;
                });
              },
            ), */
            SizedBox(height: 20),
            TextField(
              controller: linkFeildController,
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
                /*  print('Version Number: $versionNumber');
                  print('Link: $link');
                  print('Remarks: $remarks'); */
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

    Map<String, dynamic> data = {
      'platform': 'android',
      'date': DateTime.now().toIso8601String(),
      'version': versionNumber,
      'comments': comments,
      'url': linkFeildController.text,
    };

    print(linkFeildController.value.text);
    //debugger(when: true);
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
          await dio.post(url, data: data, options: Options(headers: headers));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.data[0]['version'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        _tabController.animateTo(0);
      } else {
        print(response.statusMessage);
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
      debugger(when: true);
      // TODO
    }
  }

  void _getVersion(id) async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url =
        "https://ws.kseb.in/resource/api/erp/group1/app_versions/${id}";

    try {
      Response response =
          await dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.data[0]['version'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
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
      debugger(when: true);
      // TODO
    }
  }

  void _deleteVersion(id) async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url =
        "https://ws.kseb.in/resource/api/erp/group1/app_versions/${id}";

    /*  Map data = {};
    data['version'] = versionNumber;
    data['url'] = link;
    data['comments'] = comments;
    data['platform'] = 'android';
    data['date'] = new DateTime.now(); */

    Map<String, dynamic> data = {
      'platform': 'android',
      'date': DateTime.now().toIso8601String(),
      'version': versionNumber,
      'comments': comments,
      'url': link,
    };

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
          await dio.delete(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.data[0]['version'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
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
      debugger(when: true);
      // TODO
    }
  }

  void _updateVersion(id) async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url =
        "https://ws.kseb.in/resource/api/erp/group1/app_versions/${id}";

    /*  Map data = {};
    data['version'] = versionNumber;
    data['url'] = link;
    data['comments'] = comments;
    data['platform'] = 'android';
    data['date'] = new DateTime.now(); */

    Map<String, dynamic> data = {
      'platform': 'android',
      'date': DateTime.now().toIso8601String(),
      'version': versionNumber,
      'comments': comments,
      'url': link,
    };

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
          await dio.put(url, data: data, options: Options(headers: headers));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: response.data[0]['version'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
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
      debugger(when: true);
      // TODO
    }
  }
}
