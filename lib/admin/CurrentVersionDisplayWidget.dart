import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:samagra/coming_soon.dart';
import 'package:samagra/common.dart';
import 'package:samagra/common_styles.dart';
import 'package:samagra/environmental_config.dart';

import '../check_jwt_expiry.dart';
import '../screens/set_access_toke_and_api_key.dart';

class CurrentVersionDisplayWidget extends StatelessWidget {
  const CurrentVersionDisplayWidget({
    super.key,
    required EnvironmentConfig config,
  });

  Future _listVersions() async {
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
    //debugger(when: true);
    String url = "https://ws.kseb.in/resource/api/erp/group1/app_versions";

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

        return response.data;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _listVersions(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return ComingSoon();
          }

          return Column(
            children: [
              Text('Current version'),
              _buildListItem(context, snapshot.data[0]) as Widget,
            ],
          );
        });
  }

  Widget? _buildListItem(context, item) {
    return SizedBox(
        width: 200,
        height: 200,
        child: Table(
          children: [
            TableRow(
              decoration: BoxDecoration(
                  gradient: india(),
                  color: Colors.grey,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(2)),
              children: [
                Text("Date "),
                Text(item['date']),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(
                  gradient: india(),
                  color: Colors.grey,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(2)),
              children: [
                Text("Version "),
                Text(item['version']),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(
                  gradient: india(),
                  color: Colors.grey,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(2)),
              children: [
                Text("Platform"),
                Text(item['platform']),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(
                  gradient: india(),
                  color: Colors.grey,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(2)),
              children: [
                Text("url"),
                Text(item['url']),
              ],
            ),
          ],
        )

        /*    Column(
        children: [
          Text(item['date']),
          Spacer(),
          Text(item['version']),
          Spacer(),
          Text(item['comments']),
          Spacer(),
          Text(item['url']),
          Spacer(),
          Text(item['platform']),
        ],
      ), */
        );
    print('item builder');

    print(context);
  }
}
