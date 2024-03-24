import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/screens/show_work_code.dart';
import 'package:samagra/screens/warning_message.dart';
import 'package:samagra/screens/work_details.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../secure_storage/secure_storage.dart';
import 'dart:math' as math;

// import 'package:samagra/common.dart';

import 'get_login_details.dart';
import 'get_work_details.dart';
import 'measurement_option.dart';
import 'package:samagra/environmental_config.dart';

final WorkInfoProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class WorkSelection extends StatefulWidget {
  @override
  State<WorkSelection> createState() => _WorkSelectionState();
}

class _WorkSelectionState extends State<WorkSelection> {
  final storage = SecureStorage();

  var _loaded = false;
  List measurementSetList = [];

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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // printWidgetTree(context);

          Navigator.pushNamed(context, '/home');

          // Navigator.pushReplacementNamed(context, '/home');
          // Swiped from left to right (right to left motion)
          print('Swipe back detected!');
          // Your custom handling for swipe back
        }
      },
      onHorizontalDragStart: (details) {
        // if (details.primaryVelocity! > 0) {
        if (true) {
          // printWidgetTree(context);

          Navigator.pop(context);

          // Navigator.pushReplacementNamed(context, '/home');
          // Swiped from left to right (right to left motion)
          print('Swipe back detected!');
          // Your custom handling for swipe back
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          backgroundColor: ksebMaterialColor,
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
        body: Hero(
          tag: 'Works',
          child: Theme(
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

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SchGrpListWidget(workListList),
                  );

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
                      child: SpinKitCubeGrid(size: 100.0, color: ksebColor));
                  // return rotatingProgress();
                }
              },
            ),
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
      EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
      final dio = Dio();
      final url = '${config.liveServiceUrl}wrk/getLabourMaster/0';
      final url2 = '${config.liveServiceUrl}wrk/getMaterialMaster/2/0';

      final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

      String accessToken = await getAccessToken();
      setDioAccessokenAndApiKey(dio, accessToken, config);

      // print(url);

      // debugger(when: true);
      final response = await dio.get(url, options: Options(headers: headers));

      // print('lab  called');

      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
      final responseMaterial =
          await dio.get(url2, options: Options(headers: headers));
//
      // print('materail master called');
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
    if (_loaded) {
      return measurementSetList;
    }

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
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final url =
        '${config.liveServiceUrl}wrk/getScheduleListForNormalMeasurement/$officeId';
    final headers = {'Authorization': 'Bearer $accessToken'};
    Dio dio = Dio();

    // debugger(when: true);
    try {
      String seatId = await getSeatId();

      // var u = ${config.liveServiceUrl;};

      // debugger(when: true);

      ;

      Response<dynamic> responseEdit = await fetchStoredEditListFromSamagra(
          config, dio, accessToken, seatId, headers);

      var res2 = responseEdit.data['result_data'];

      if (res2 != null) {
        measurementSetList = res2['measurement_set_list'];
      } else {
        measurementSetList = [];
      }

      // print('response edit $measurement_set_list');
      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
      Response response =
          await dio.get(url, options: Options(headers: headers));

      // print(response);

      // debugger(when: true);

      // debugger(when: true);
      //write code here to action for no work code error code -1 display error etc

      if (response.data['result_data'] != null &&
          response.data['result_data']['schGrpList'] != null) {
        var res1 = response.data['result_data']['schGrpList'];

        measurementSetList.forEach(
          (element) {
            element['workId'] = element['plg_work_id'];

            //  element['wrk_schedule_group_id'] = element['wrk_schedule_group_id'];

            // print('element measurement_set_list  work id ${element['workId']}');
          },
        );

        res1.forEach((element) {
          // element['workId'] = element['plg_work_id'];
          element['workId'] = element['plg_work_id'];

          element['wrk_schedule_group_id'] = element['id'];
        });
        // debugger(when: true);
        measurementSetList.addAll(res1);

        List res = measurementSetList;
        // res.addAll(measurement_set_list);

        // print(res);

        // debugger(when: true);

        // debugger(when: true);
        // res.forEach((r) async => {print("R  $r")});

        //  Future<Map<String, dynamic>?> wd = await getWorkDetails(workId.toString());

        // print("WD this is WD $wd");

        // this.callApiAndSaveLabourGroupMasterInSecureStorage();

        // debugger(when: true);

        // setState(() {
        //   _loaded = !_loaded;
        // });

        return res;
      } else {
        p('some error $url');

        // setState(() {
        //   _loaded = !_loaded;
        // });

        return [];
      }
    } on Exception catch (e, stackTrace) {
      // Added stackTrace parameter for better error reporting
      if (context != null && context != -1) {
        // Checking if context is not null
        // debugger(when: true);

        print(e);
        print(url);

        // debugger(when: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                style: TextStyle(backgroundColor: ksebMaterialColor),
                'Some Error  in Accesing Servor Retrying $url'
                    .toString()), // Accessing exception using e.toString() instead of e['message']
            duration: Duration(seconds: 10),
          ),
        );

        // print(context);
      }

      // print(e); // Logging the exception
      print(stackTrace); // Logging the stack trace for better debugging

      // setState(() {
      //   _loaded = !_loaded;
      // });

      return Future.value(['-1']);
    }
  }

  Future<Response<dynamic>> fetchStoredEditListFromSamagra(
      EnvironmentConfig config,
      Dio dio,
      accessToken,
      String seatId,
      Map<String, String> headers) async {
    String urlEdit =
        "${config.liveServiceUrl}wrk/getPolevarMeasurementSetListForEdit";

    setDioAccessokenAndApiKey(dio, accessToken, config);

    Response responseEdit = await dio.get(
      queryParameters: Map.from({'seat_id': seatId}),
      urlEdit,
      options: Options(headers: headers),
    );
    return responseEdit;
  }

  refreshWorkList() {
    _fetchWorkListList();
  }
}

class rotatingProgress extends StatelessWidget {
  const rotatingProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedBuilder(
            animation: AlwaysStoppedAnimation(0.0),
            builder: (context, child) {
              var angle = 2 * pi * DateTime.now().second / 60;
              return Transform.rotate(angle: angle, child: progress());
            }));
  }
}

class progress extends StatelessWidget {
  const progress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularStepProgressIndicator(
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
    );
  }
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
  void toggleMute() {
    setState(() {
      isAudioMuted = !isAudioMuted;

      // WorkDetails.isAudioMuted = !WorkDetails.isAudioMuted;
    });
  }

  var isAudioMuted = false;

  getStoredWorkDetails(workId) async {
    final storage = new FlutterSecureStorage();

    String? jsonDetails = await storage.read(key: 'measurementDetails');

    if (jsonDetails != null) {
      List<dynamic> details = jsonDecode(jsonDetails);

      Map<dynamic, dynamic> matchingDetail = details
          .firstWhere((detail) => detail['workId'] == workId, orElse: () => {});

      bool hasStarted = matchingDetail.isNotEmpty;

      return {
        'matchingDetail': matchingDetail,
        'detailsList': details,
        hasStarted: hasStarted
      };
    }
    return {'matchingDetail': {}, 'detailsList': []};
  }

  setWorKdetails(_filteredItems) async {
    _filteredItems.forEach((i) async {
      if (i == '-1') {
        return;
      }

      // bool hasStarted = await getStoredWorkDetails(i['plg_work_id']).hasStarted;

      // i.hasStarted = hasStarted;
      // if (i == "-1") {
      //   return;
      // }

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

    setState(() {});
  }

  @override
  void initState() {
    audioCache = AudioCache(prefix: 'assets/audio/');
    _filteredItems = List.from(widget.schGrpList);
    setWorKdetails(_filteredItems);

    // print(_filteredItems);

    super.initState();

    if (!isAudioMuted) {
      // audioCache.play('select_work.wav');
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer(builder: (context, ref, child) {
      final workDetails = ref.watch(workDetailsProvider);

      // debugger(when: true);
      return SafeArea(
        child: Column(
          children: [
            // IconButton(
            //   iconSize: 10,
            //   icon: isAudioMuted
            //       ? Icon(Icons.volume_up_rounded)
            //       : Icon(Icons.volume_mute_sharp),
            //   onPressed: toggleMute,
            //   tooltip: isAudioMuted ? 'Unmute Audio' : 'Mute Audio',
            // ),
            Padding(
              padding: const EdgeInsets.all(5.0),
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
              child: normalListView(),
              // child: normalListWheelScrollView()
            ),
          ],
        ),
      );
    });
  }

  GridView normalListView() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.7,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];

        if (item == "-1") {
          return WarningMessage(message: 'No work Found For Measurement');
          // return Text(
          //     'some error -1 in item Failed to load List of Works');
          // showErrorSnackBar(context);
        }

        int sl = index + 1;

        Map workDetail = item['wrk_work_detail'];

        int workId = item?['workId'];

        int workScheduleGroupId = item?['wrk_schedule_group_id'];

        final workName = workDetail['work_name'];
        final workCode = workDetail['work_code'];
        final status = item['status'];

        final measurementSetId = (status == 'CREATED') ? -1 : item['id'];

        if (workName == null || workId == -1 || item == "-1") {
          showErrorSnackBar(context);
        }

        final WorkNameProvider = Provider<String>((ref) => workName);

        return GestureDetector(
            onTap: () {
              ///setting global work details
              WorkDetails workDetails = WorkDetails();

              // Setting properties
              workDetails.workName = workName;
              workDetails.workCode = workCode;
              workDetails.workId = workId;
              workDetails.isAudioMuted = true;

              // print(
              //     "workDetails.isAudioMuted ${workDetails.isAudioMuted}");

              // debugger(when: true);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MeasurementOptionScreen(
                    workId,
                    workName,
                    workCode,
                    measurementSetId.toString(),
                    workScheduleGroupId.toString(),
                    isAudioMuted,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: ksebColor,
                    width: 2,
                    style: BorderStyle.solid),
              ),
              child: GridTile(
                footer: ShowWorkCode(workCode: workCode),
                header: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WorkTitle(
                      workId: workId,
                      workScheduleGroupId: workScheduleGroupId,
                      status: status),
                ),
                child: Center(
                  child: ListTile(
                    // subtitle: SizedBox(
                    //     width: 30,
                    //     height: 30,
                    //     child: Image.asset('assets/images/kseb.jpg')),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    visualDensity: VisualDensity.compact,
                    focusColor: ksebColor,
                    // title:
                    leading: CircleAvatar(
                      child: Text(sl.toString()),
                      radius: 10,
                    ),
                    hoverColor: ksebColor,
                    splashColor: ksebColor,
                    tileColor: (status != 'CREATED')
                        ? Color.fromARGB(255, 33, 194, 151)
                        : Colors.white,
                    // subtitle: item['started'] == true
                    //     ? Text(
                    //         "No of Locations Mdeasures ${item['noOflocationMeasured']}")
                    //     : Text(
                    //         'Measurements Not Started ${item['hasStarted']}'),
                    title: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Text(
                              item['wrk_work_detail']['work_name'],
                              style: TextStyle(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  fontFamily: 'verdana',
                                  textBaseline: TextBaseline.ideographic,
                                  fontSize: 18,
                                  wordSpacing: 3,
                                  color:
                                      const Color.fromARGB(255, 89, 76, 175)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

// ListWheelScrollView(

  ListWheelScrollView normalListWheelScrollView() {
    return ListWheelScrollView(
      useMagnifier: true,
      itemExtent: 150, // Height of each item
      diameterRatio: 6, // Determines the size of the wheel
      children: List.generate(
        _filteredItems.length,
        (index) {
          final item = _filteredItems[index];

          if (item == "-1") {
            return WarningMessage(message: 'No work Found For Measurement');
          }

          int sl = index + 1;

          Map workDetail = item['wrk_work_detail'];
          int workId = item?['workId'];
          int workScheduleGroupId = item?['wrk_schedule_group_id'];
          final workName = workDetail['work_name'];
          final workCode = workDetail['work_code'];
          final status = item['status'];
          final measurementSetId = (status == 'CREATED') ? -1 : item['id'];

          if (workName == null || workId == -1 || item == "-1") {
            showErrorSnackBar(context);
          }

          return GestureDetector(
            onTap: () {
              WorkDetails workDetails = WorkDetails();
              workDetails.workName = workName;
              workDetails.workCode = workCode;
              workDetails.workId = workId;
              workDetails.isAudioMuted = true;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MeasurementOptionScreen(
                    workId,
                    workName,
                    workCode,
                    measurementSetId.toString(),
                    workScheduleGroupId.toString(),
                    isAudioMuted,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                title: Text(
                  item['wrk_work_detail']['work_name'],
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 89, 76, 175),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'WorkCode: $workCode',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 236, 143, 11),
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  child: Text(sl.toString()),
                  radius: 20,
                ),
                trailing: (status != 'UNDR_MSR')
                    ? Text(status)
                    : Text('Status not available'),
                tileColor: (status != 'CREATED')
                    ? Color.fromARGB(255, 33, 194, 151)
                    : Colors.white,
              ),
            ),
          );
        },
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

class WorkTitle extends StatelessWidget {
  const WorkTitle({
    super.key,
    required this.workId,
    required this.workScheduleGroupId,
    required this.status,
  });

  final int workId;
  final int workScheduleGroupId;
  final status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            Text('WorkId :$workId'),
            Spacer(),
            Text('Work Group Id :$workScheduleGroupId'),
            /*  Spacer(),
            (status != 'UNDR_MSR') ? Text('Status: ' + status) : Text('k'), */
          ],
        ),
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
