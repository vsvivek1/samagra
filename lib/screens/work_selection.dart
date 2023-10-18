import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/app_theme.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../secure_storage/secure_storage.dart';
import 'dart:math' as math;
// import 'package:samagra/common.dart';

import 'get_login_details.dart';
import 'get_work_details.dart';
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
    return WillPopScope(
      onWillPop: () async {
        print('this callsed');
        debugger(when: true);

        // Navigator.of(context).pushReplacementNamed('/redirected');
        return false; // Prevent default back button behavior

        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
        // );
        // // Navigator.push(
        // //   context,
        // //   MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
        // // );
        // return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.grey.withOpacity(0.7),
          title: Row(
            children: [
              Spacer(),
              Text('Select a Work'),
              Spacer(),
              IconButton(
                  color: Colors.red,
                  onPressed: refreshWorkList(),
                  icon: Icon(Icons.refresh))
            ],
          ),
        ),
        body: Theme(
          data: ThemeData(),
          child: FutureBuilder(
            future: _fetchWorkListList(context: context),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != "-1") {
                final workListList = snapshot.data;

                // print("worklist $workListList");

                // debugger(when: true);

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
              } else if (snapshot.hasError || snapshot.data == '-1') {
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
      ),
    );
  }

  Future<String> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');
    return Future.value(accessToken);
  }

  Future<void> callApiAndSaveLabourGroupMasterInSecureStorage() async {
    try {
      final dio = Dio();
      final url = 'http://erpuat.kseb.in/api/wrk/getLabourMaster/0';
      final url2 = 'http://erpuat.kseb.in/api/wrk/getMaterialMaster/2/0';

      final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
      final response = await dio.get(url, options: Options(headers: headers));

      // print('lab  called');
      final responseMaterial =
          await dio.get(url2, options: Options(headers: headers));
//
      print('materail master called');
      var inp = response.data['result_data']['labourMaster'];

      var mat = responseMaterial.data['result_data']['materialMaster'];

      // print('mat called');

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

      // print(a1);

      // print('a1');
    } catch (e) {
      print(e);

      print('error');
    }

    return;
  }

  Future<List<dynamic>> _fetchWorkListList({context = -1}) async {
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
      String seatId = await getSeatId();
      final urlEdit =
          "http://erpuat.kseb.in/api/wrk/getPolevarMeasurementSetListForEdit";

      // print(urlEdit);
      Response responseEdit = await Dio().get(
        queryParameters: Map.from({'seat_id': seatId}),
        urlEdit,
        options: Options(headers: headers),
      );

// await Dio().get(queryParameters:
      var res2 = responseEdit.data['result_data'];
      List measurement_set_list = res2['measurement_set_list'];
      // print('response edit $measurement_set_list');

      Response response =
          await Dio().get(url, options: Options(headers: headers));
      //write code here to action for no work code error code -1 display error etc
      // p(response.data['result_data']);

      // print(response.data.runtimeType);
      // print("res data. ${response.data}");
      // print("res data. ${response['data']}");
      // debugger(when: true);
      // debugger(when: true);
      if (response.data['result_data'] != null &&
          response.data['result_data']['schGrpList'] != null) {
        var res1 = response.data['result_data']['schGrpList'];

        measurement_set_list.forEach(
          (element) {
            element['workId'] = element['plg_work_id'];

            print('element measurement_set_list  work id ${element['workId']}');
          },
        );

        res1.forEach((element) {
          // element['workId'] = element['plg_work_id'];
          element['workId'] = element['plg_work_id'];
          print('element normal ${element['workId']} ');
        });
        // debugger(when: true);
        measurement_set_list.addAll(res1);

        List res = measurement_set_list;
        // res.addAll(measurement_set_list);

        // print(res);

        // debugger(when: true);

        // debugger(when: true);
        // res.forEach((r) async => {print("R  $r")});

        //  Future<Map<String, dynamic>?> wd = await getWorkDetails(workId.toString());

        // print("WD this is WD $wd");

        this.callApiAndSaveLabourGroupMasterInSecureStorage();
        // debugger(when: true);
        return res;
      } else {
        p('some error');
        return [];
      }
    } on Exception catch (e) {
      if (context != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This is a SnackBar!'),
            duration: Duration(seconds: 2),
          ),
        );

        // print(context);
      }

      print(e); // TODO
      return Future.value(['-1']);
    }
  }

  refreshWorkList() {
    _fetchWorkListList();
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

  setWorKdetails(_filteredItems) async {
    _filteredItems.forEach((i) async {
      if (i == "-1") {
        return;
      }

      var vd = await getWorkDetails(i["workId"].toString());

      if (vd != null) {
        var measurements = vd['measurements'];

        i['measurements'] = measurements;

        if (measurements != null) {
          i['noOflocationMeasured'] = measurements.length;
          i['started'] = measurements.length > 0 ? true : false;

          print("VD is $vd");
        }
      }
    });
  }

  @override
  void initState() {
    audioCache = AudioCache(prefix: 'assets/audio/');
    _filteredItems = List.from(widget.schGrpList);
    setWorKdetails(_filteredItems);

    // print(_filteredItems);

    super.initState();

    audioCache.play('select_work.wav');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Work code or Work Name',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _filteredItems = List.from(widget.schGrpList);
                      });
                    },
                  ),
                ),
              ),
              onChanged: (value) {
                List<dynamic> schGrpList = List.from(widget.schGrpList);
                setState(() {
                  _filteredItems = schGrpList
                      .where((item) =>
                          item['wrk_work_detail']['work_name']
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          item['wrk_work_detail']['work_code']
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];

                if (item == "-1") {
                  return Text(
                      'some error -1 in item Failed to load List of Works');
                  // showErrorSnackBar(context);
                }

                int sl = index + 1;

                Map workDetail = item['wrk_work_detail'];

                // int hasTakenback=

                // int workId = workDetail?['id'];
                int workId = item?['workId'];
                int workScheduleGroupId = item?['id'];

                final workName = workDetail['work_name'];
                final workCode = workDetail['work_code'];
                final status = item['status'];
                final measurementSetId =
                    (status == 'CREATED') ? -1 : item['id'];

                // debugger(when: workCode == 'CW-6661-202223-15');
                // print(work)

                if (workName == null || workId == -1 || item == "-1") {
                  showErrorSnackBar(context);
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
                              workId,
                              workName,
                              workCode,
                              measurementSetId.toString(),
                              workScheduleGroupId.toString()),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: GridTile(
                        header: Row(
                          children: [
                            CircleAvatar(child: Text(sl.toString())),
                            Spacer(),
                            Text('WorkId :$workId'),
                            Spacer(),
                            Text('SchGrp :$workScheduleGroupId'),
                            Spacer(),
                            (status != 'UNDR_MSR') ? Text(status) : Text('k'),
                          ],
                        ),
                        child: Center(
                          child: ListTile(
                            tileColor: (status != 'CREATED')
                                ? Color.fromARGB(255, 33, 194, 151)
                                : Colors.white,
                            subtitle: item['started'] == true
                                ? Text(
                                    "No of Locations Mdeasures ${item['noOflocationMeasured']}")
                                : Text(
                                    'Measurements Not Started ${item['noOflocationMeasured']}'),
                            title: Text('\n\n' +
                                item['wrk_work_detail']['work_name'] +
                                '\n' +
                                '\n WorkCode: $workCode'),
                          ),
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

  void showErrorSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Some error caused to load work id go back and try again'),
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
}

class OptionScreen extends StatelessWidget {
  final int itemId;
  final String itemName;

  OptionScreen({required this.itemId, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: null,
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
