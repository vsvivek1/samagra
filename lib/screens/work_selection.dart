import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/app_theme.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../secure_storage/secure_storage.dart';
import 'package:samagra/secure_storage/common_functions.dart';
import 'dart:math' as math;
// import 'package:samagra/common.dart';

import 'measurement_option.dart';

class WorkSelection extends StatelessWidget {
  final storage = SecureStorage();

  void p(name, [String from = '']) {
    print('-----------------------');
    print(from);

    print("${#name.toString} = $name");

    // print(msg);
    print('-----------------------');
  }

  @override
  Widget build(BuildContext context) {
    InternetConnectivity.showInternetConnectivityToast(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.grey.withOpacity(0.7),
        title: Text('Select an Work'),
      ),
      body: Theme(
        data: ThemeData(buttonColor: AppTheme.grey.withOpacity(0.9)),
        child: FutureBuilder(
          future: _fetchWorkListList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final workListList = snapshot.data;

              // p(WorkListList);
              // p(workListList.runtimeType);

              // return Text(WorkListList.toString());

              return SchGrpListWidget(workListList);

              // return MaterialApp(
              //   title: 'List of Works',
              //   home: Scaffold(
              //     appBar: AppBar(
              //       title: Text('Square Tiles Demo'),
              //     ),
              //     body: WorkListListWidget(WorkListList),
              //   ),
              // );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Center(
                  child: CircularStepProgressIndicator(
                totalSteps: 20,
                currentStep: 12,
                stepSize: 20,
                selectedColor: Colors.red,
                unselectedColor: Colors.purple[400],
                padding: math.pi / 80,
                width: 150,
                height: 150,
                startingAngle: -math.pi * 2 / 3,
                arcSize: math.pi * 2 / 3 * 2,
                gradientColor: LinearGradient(
                  colors: [Colors.red, Colors.purple],
                ),
              ));
            }
          },
        ),
      ),
    );
  }

  Future<String> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');
    return Future.value(accessToken);
  }

  Future<void> callApiAndSaveLabourGroupMasterInSecureStorage() async {
    final dio = Dio();
    final url = 'http://erpuat.kseb.in/api/wrk/getLabourMaster/0';
    final url2 = 'http://erpuat.kseb.in/api/wrk/getMaterialMaster/2/0';

    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
    final response = await dio.get(url, options: Options(headers: headers));

    print('lab  called');
    final responseMaterial =
        await dio.get(url2, options: Options(headers: headers));
//
    print('materail master called');

    try {
      var inp = response.data['result_data']['labourMaster'];

      var mat = responseMaterial.data['result_data']['materialMaster'];

      print('mat called');

      var store = inp
          .map((a) => {
                // print(a)

                // ignore: unnecessary_statements
                'id': a['id'],
                'key': a['code'],
                'code': a['code'],
                'uom': a['mst_uom']['uom_code'],
                'rate': a['rate'],

                'name': a['name'], 'mst_uom_id': a['mst_uom_id']

                // {a.id, a.code, a.name, a.uom}
              })
          .toList();

      var mapStore = mat
          .map((a) => {
                // print(a)

                // ignore: unnecessary_statements
                'id': a['id'],
                'key': a['material_code'],
                'code': a['material_code'],
                'uom': a['mst_stock_uom']['uom_code'],
                'rate': a['mst_material_rates'][0]['rate'],

                'name': a['name'], 'mst_uom_id': a['mst_uom_id'],

                // {a.id, a.code, a.name, a.uom}
              })
          .toList();

      // print(store);

      // print('response data');

      final secureStorage = FlutterSecureStorage();
      await secureStorage.write(
          key: 'getLabourGroupMaster', value: json.encode(store));

      await secureStorage.write(
          key: 'getMaterialGroupmaster', value: json.encode(mapStore));

      var a1 = await secureStorage.read(key: 'getLabourGroupMaster');

      print(a1);

      print('a1');
    } catch (e) {
      print(e);

      print('error');
    }

    return;
  }

  Future<List<dynamic>> _fetchWorkListList() async {
    final accessToken1 =
        await storage.getSecureAllStorageDataByKey("access_token");

    final accessToken = accessToken1['access_token'];
    final loginDetails1 =
        await storage.getSecureAllStorageDataByKey('loginDetails');
    final loginDetails = loginDetails1['loginDetails'];

    final currentSeatDetails = getCurrentSeatDetails(loginDetails);

    // final officeCode = currentSeatDetails['office']['office_code'];
    final officeId = currentSeatDetails['office_id'];
    // final officeCode = 1234;
    final url =
        'http://erpuat.kseb.in/api/wrk/getScheduleListForNormalMeasurement/$officeId';
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));

      //write code here to action for no work code error code -1 display error etc
      // p(response.data['result_data']);

      if (response.data != null &&
          response.data['result_data'] != null &&
          response.data['result_data']['schGrpList'] != null) {
        var res = response.data['result_data']['schGrpList'];

        this.callApiAndSaveLabourGroupMasterInSecureStorage();

        return res;
      } else {
        p('some error');
        return [];
      }
    } on Exception catch (e) {
      return Future.value(['hi']);
      print(e); // TODO
    }
  }

  ///SchGrp is WorkList for readability
}

class SchGrpListWidget extends StatefulWidget {
  final dynamic schGrpList;

  SchGrpListWidget(this.schGrpList);

  @override
  _SchGrpListWidgetState createState() => _SchGrpListWidgetState();
}

class _SchGrpListWidgetState extends State<SchGrpListWidget> {
  final _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];
  late AudioCache audioCache;

  String workCode = '';

  @override
  void initState() {
    audioCache = AudioCache(prefix: 'assets/audio/');
    _filteredItems = List.from(widget.schGrpList);

    super.initState();

    audioCache.play('select_work.wav');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _filteredItems = List.from(widget.schGrpList);
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  List<dynamic> schGrpList = List.from(widget.schGrpList);
                  setState(() {
                    _filteredItems = schGrpList
                        .where((item) => item['wrk_work_detail']['work_name']
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];

                int sl = index + 1;

                Map workDetail = item['wrk_work_detail'];

                // int hasTakenback=

                // int workId = workDetail?['id'];
                int workId = item?['id'];
                final workName = workDetail['work_name'];
                final workCode = workDetail['work_code'];

                if (workName == null || workId == -1) {
                  final snackBar = SnackBar(
                    content: Text(
                        'Some error caused to load work id go back and try again'),
                    action: SnackBarAction(
                      label: 'Go Back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  print('work_name key not found in map or its value is null');
                }

                ///temporary

                //  'workId' : workId,
                //             'workName': workName,

                // return Text('hi');
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MeasurementOptionScreen(
                              workId, workName, workCode),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: GridTile(
                        header: Text(sl.toString()),
                        child: Center(
                          child: Text(item['wrk_work_detail']['work_name'] +
                              '\n\n' 'WorkId :$workId'),
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OptionScreen extends StatelessWidget {
  final int itemId;
  final String itemName;

  OptionScreen({required this.itemId, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(itemName),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to direct measuring screen
            },
            child: Text('Direct Measuring'),
          ),
          SizedBox(height: 16.0),
          // ElevatedButton(
          // onPressed: () {
          //   // Navigate to pol
        ])));
  }
}
