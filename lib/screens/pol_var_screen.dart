import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/screens/editable_table.dart';
import 'package:samagra/screens/location_details_widget.dart';

import '../app_theme.dart';
import '../secure_storage/secure_storage.dart';
import 'package:collection/collection.dart';

import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

import 'measurement_display_widget.dart';

class PolVarScreen extends StatefulWidget {
  @override
  final int workId;
  final String workName;

  PolVarScreen({Key? key, required this.workId, required this.workName})
      : super(key: key) {}

  _PolVarScreenState createState() => _PolVarScreenState();
}

class _PolVarScreenState extends State<PolVarScreen> {
  final storage = SecureStorage();
  int _numberOfLocations = 0;
  int _selectedLocationIndex = -1;
  int _previoslySelectedIndex = -1;
  late AudioCache audioCache;

  bool viewStructures = false;

  String userDirections = 'Watch here to Know what to do next';

  bool _enableEntryOfLocationDetails = true;

  String _fromLocation = '';
  String _toLocation = '';
  int _tappedIndex = -1;

  int steps = 0;

  Map<String, dynamic> _selectedLocationDetails = {};

  List _selectedMeasurements = [];
  List<Map<String, dynamic>> _masterMaterialEstimate = [];
  List<Map<String, dynamic>> _masterLabEstimateItems = [];

  List _tasks = [];

  List _taskList = [];

  bool isPlaying = false;
  bool isMuted = false;

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void stop() {
    setState(() {
      isPlaying = false;
    });
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  Future<Map<String, dynamic>> getMeasurementDetails(
      String workId, int locationNumber) async {
    final storage = new FlutterSecureStorage();
    String? jsonDetails = await storage.read(key: 'measurementDetails');
    if (jsonDetails != null) {
      List<dynamic> details = jsonDecode(jsonDetails);
      Map<dynamic, dynamic> matchingDetail = details.firstWhere(
          (detail) =>
              detail['workId'] == workId &&
              detail['locationNumber'] == locationNumber,
          orElse: () => {});
      return {'matchingDetail': matchingDetail, 'detailsList': details};
    }
    return {'matchingDetail': {}, 'detailsList': []};
  }

  Future<void> storeMeasurementDetails(
      List<Map<String, dynamic>> measurementDetails) async {
    final storage = new FlutterSecureStorage();
    String jsonDetails = jsonEncode(measurementDetails);
    await storage.write(key: 'measurementDetails', value: jsonDetails);
  }

  bool loadingLocationDetails = false;
  List<Map<String, dynamic>> measurementDetails = [];

  List<Map<String, dynamic>> measurementDetails1 = [
    {
      'locationNo': 1,
      'locationName': 'my location',
      'geoCordinates': {'lattitude': '0', 'longitude': 0, 'name': 0},
      "tasks": [
        {
          'taskId': 1,
          'taskName': 'sample',
          'taskQty': 1,
          'Structures': [
            {
              'Structurename': 'pole',
              "Structureid": 1,
              'materials': [
                {'itemname': 'itemname', "quantity": "1"}
              ],
              'labour': [
                {'itemname': 'labour1', "quantity": "2"}
              ]
            }
          ]
        }
      ]
    }
  ];

  Map<dynamic, dynamic>? _workDetails;

  /// save this if this is present
  // List<String> _templates = [

  List<String> _selectedTemplates = [];

  // get workName => this.workName;

  List getStructuresByName(d) {
    print(d);

    print('dabove 144');
    // return;
    List<dynamic> tasks = d;

    List res = [];

    var allTasks =
        tasks.map((t) => t['mst_task']['task_name']).toSet().toList();

    var allTasksIds = tasks.map((t) => t['mst_task']['id']).toSet().toList();

    print(allTasksIds);

    print('all task id above @157n pol var');

    for (int z = 0; z < allTasks.length; z++) {
      var ta = allTasks[z];

      var taskId = allTasksIds[z];

      // print('tasks above');

      var t2 = tasks
          .where((t) => t['mst_task']['task_name'] == ta)
          .map((t3) => t3['mst_structure']);

      var mstTaskId =
          tasks.where((t) => t['id'] == taskId).map((t3) => t3['id']);

      // print('mst_structure_id avbvove');

      var ob = {};
      ob['taskId'] = taskId;
      ob['task_name'] = ta;
      ob['isExpanded'] = false;
      ob['tasks'] = t2;

      print('$ta  $taskId is task id');
      res.add(ob);
    }

    return res;
  }

  Future<Map<String, String?>?> getWorkDetails(String workId) async {
    final storage = FlutterSecureStorage();
    // Get existing work details from secure storage, if any
    final existingDetails = await storage.read(key: 'workDetails') ?? '{}';
    final workDetails = Map<String, dynamic>.from(json.decode(existingDetails));

    // Return work details for the given workId, if present
    final workData = workDetails[workId];
    if (workData != null) {
      return Map<String, String?>.from(workData);
    } else {
      return null;
    }
  }

  Future<void> saveWorkDetails({
    required String workId,
    String? longitude,
    String? latitude,
    String? locationName,
    String? fromLocation,
    String? toLocation,
    String? measurementDetails,
    String? noOfLocations,
  }) async {
    // Get existing work details from secure storage, if any

    final storage = FlutterSecureStorage();
    final existingDetails = await storage.read(key: 'workDetails') ?? '{}';
    final workDetails = Map<String, dynamic>.from(json.decode(existingDetails));

    // Update work details with new data, if any
    final workData = <String, String?>{
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'latitude': latitude,
      if (locationName != null) 'locationName': locationName,
      if (measurementDetails != null) 'measurementDetails': measurementDetails,
      if (fromLocation != null) 'fromLocation': fromLocation,
      if (toLocation != null) 'toLocation': toLocation,
      if (noOfLocations != null) 'noOfLocations': noOfLocations,
    };
    workDetails[workId] = workData;

    // Store updated work details securely
    await storage.write(key: 'workDetails', value: json.encode(workDetails));
  }

  Future _sheduleBuilder() async {
    var workDetails = await _fetchWorkDetails(); //.then((workDetails) {

    if (workDetails.length == 1 && workDetails[0] == -1) {
      return Future.value(-1);
    }
    List wrkScheduleGroupStructures =
        workDetails[0]['wrk_schedule_group_structures'];

    // print(workDetails);
    // print('workDetails above');

    var c = getStructuresByName(wrkScheduleGroupStructures).toList();
    // var c = getStructuresByName(workDetails).toList();

    _tasks = c;
    print(c);

    var taskln = c.length;

    print(' $taskln TASK LENGTH task list structure s see abobe 215');

    return Future.value(c.toList());
  }

  Future<void> initialSetup() async {
    await _updateWorkDetailsOnLoading();
    audioCache = AudioCache(prefix: 'assets/audio/');

    print('$_numberOfLocations is numberof locations at 230');

    if (_enableEntryOfLocationDetails) {
      setState(() {
        this.steps = this.steps++;
        if (_numberOfLocations == 0) {
          this.userDirections = 'Enter Number of Locations';
          audioCache.play('no_of_loc.mp3');
        } else if (!(_numberOfLocations > 0) && _fromLocation == '' ||
            _toLocation == '') {
          this.userDirections = 'Please Enter From and To Locations';
          audioCache.play('enter_from_to_location_name.wav');
        } else if (_fromLocation != '' &&
            _toLocation != '' &&
            _numberOfLocations != 0) {
          this.userDirections = 'Select a Location';
          audioCache.play('select_location.wav');
        }

// else {
//   this.userDirections = 'Invalid Number of Locations';
//   audioCache.play('invalid_loc.mp3');
// }
      });
    } else {
      setState(() {
        if (_numberOfLocations > 0 &&
            _fromLocation != '' &&
            _toLocation != '') {
          this.userDirections =
              'Now Select any Location to Starting with  L, Ensure correct location ';
          audioCache.play('select_location.wav');
        }

        this.steps = 0;
        this.userDirections = 'Enter location details';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialSetup();
    // ignore: todo
    // TODO: implement initState
  }

  Future<void> _updateWorkDetailsOnLoading() async {
    final data = await getWorkDetails(widget.workId.toString());

    print(data);

    print('data above 277');

    // return;

    setState(() {
      if (data != null &&
          data['fromLocation'] != null &&
          data['toLocation'] != null &&
          data['noOfLocations'] != null) {
        _workDetails = {};

        data.forEach((key, value) {
          _workDetails![key] =
              value ?? ''; // set the value to an empty string if it's null
        });

        _fromLocation = data['fromLocation']!;
        _toLocation = data['toLocation']!;
        _numberOfLocations = int.parse(data['noOfLocations']!) > 1000
            ? 999
            : int.parse(data['noOfLocations']!);

        print(_workDetails);
        print(_workDetails.runtimeType);

        print('work details above');

        print('above issue');

        print(_workDetails!['locations']);

        print('_workDetails! above 304');

        // if (!(_workDetails!['locations'] is Map)) {

        if (_workDetails!['locations'] == null) {
          // _workDetails!['locations'] = 'hi';
          _workDetails!['locations'] ??= <dynamic, dynamic>{
            'key1': 'value1',
            'key2': 123,
            'key3': true
          };
        }

        // }

        // print(_workDetails);

        print('work details abobve $_numberOfLocations');

        _enableEntryOfLocationDetails = false;
      }
    });
  }

  _handleEmitLocDetailsToPolVarWidget(Map locDetails) async {
    setState(() {
      if (measurementDetails != null) {
        Map existingMeasurementDetails = measurementDetails.firstWhere(
            (element) => element['locationNo'] == _selectedLocationIndex,
            orElse: () => {});

        if (existingMeasurementDetails != {}) {
          print(existingMeasurementDetails);
          print('existng param above');

          print(locDetails);

          print('locDetais new above');

          existingMeasurementDetails = {
            ...existingMeasurementDetails,
            ...locDetails
          };

          print(existingMeasurementDetails);

          print('new exiasting details above');

          int indexToUpdate = measurementDetails.indexWhere(
              (details) => details['locationNo'] == _selectedLocationIndex);

          if (indexToUpdate != -1) {
            measurementDetails[indexToUpdate] =
                Map<String, dynamic>.from(existingMeasurementDetails);
          } else {
            print('adding new');

            setState(() {
              measurementDetails
                  .add(Map<String, dynamic>.from(existingMeasurementDetails));
            });

            int ln = measurementDetails.length;

            print('measurement details length ${ln}');
          }
        }

        print(existingMeasurementDetails);
        print('existing mesr detaiks above');
      }

      print('from parent location details just above as map');

      // widget.latitude = p1;
      // widget.longitude = p2;
      // widget.locationName = name;

      // widget.locationDetails['lattitude'] = p1.toString();
      // widget.locationDetails['longitude'] = p2.toString();
      // widget.locationDetails['name'] = name.toString();
      // // widget.locationDetails['name'] = name.toString();
    });

    // print(measurementDetails[2]);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      viewStructures = true;
    });

    this.userDirections =
        'NOW Select Task and then correct structure inside it ';
    audioCache.play('select_structure.wav');
    // print(this._workDetails);

    print(' measurementDetails above');
  }

  //

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _sheduleBuilder(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData &&
              snapshot.data == -1 &&
              snapshot.data == null) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var tasklist1 = snapshot.data;

          // ignore: unrelated_type_equality_checks
          if (tasklist1 == null || tasklist1 == -1) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          int ln = tasklist1.length;

          _taskList = tasklist1;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.grey.withOpacity(0.7),
                title: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        userDirections,
                        key: ValueKey<String>(userDirections),
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                      // VoiceControl(),
                    ],
                  ),
                ),
              ),
              body: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 10,
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 5,
                    margin: EdgeInsets.all(16.0),
                    child: Wrap(
                      // mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WorkNameWidget(
                          workName: widget.workName +
                              '\n\nWork Id : ${widget.workId}',
                          color: Colors.blue,
                        ),
                        enterLocationDetails(),
                        viewLocationDetails(),
                        if ((!_enableEntryOfLocationDetails &&
                            _numberOfLocations > 0 &&
                            _numberOfLocations < 999 &&
                            _fromLocation != '' &&
                            _toLocation != '')) ...[
                          Divider(
                            height: 5,
                            thickness: 2,
                            color: Colors.blueAccent,
                          ),
                          Visibility(
                            visible: _selectedLocationIndex != -1,
                            child: SizedBox(
                              height: 300,
                              width: 500,
                              child: Row(children: [
                                Column(
                                  children: [
                                    LocationDetailsWidget(
                                        locationDetails: {},
                                        updateLocationDetailsArray:
                                            _updateLocationDetailsArray,
                                        locationNo:
                                            _selectedLocationIndex.toString(),
                                        measurements: List<String>.from(
                                          _selectedMeasurements,
                                        ),
                                        emitLocDetailsToPolVarWidget:
                                            _handleEmitLocDetailsToPolVarWidget)
                                    // ,
                                    // Expanded(
                                    //     child: MeasurementDisplayWidget(
                                    //         measurementDetails))

                                    // // viewAllLocationDetails(context),
                                    // ,
                                  ],
                                )
                              ]),
                            ),
                          ),
                          // Divider(color: Colors.white10, thickness: 10),
                          // SizedBox(height: 50),
                          viewLocationList(tasklist1),
                          // viewLocationList(tasklist1),
                          SizedBox(height: 2000),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Row VoiceControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 50,
          ),
          onPressed: togglePlay,
        ),
        IconButton(
          icon: Icon(
            isMuted ? Icons.volume_off : Icons.volume_up,
            size: 50,
          ),
          onPressed: toggleMute,
        ),
        ElevatedButton(
          child: Text('Play Again'),
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
          },
        ),
        ElevatedButton(
          child: Text('Stop'),
          onPressed: stop,
        ),
      ],
    );
  }

  SizedBox viewAllLocationDetails(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      child: ListView.builder(
          // itemCount: _numberOfLocations,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                LocationDetailsWidget(
                    locationDetails: {},
                    updateLocationDetailsArray: _updateLocationDetailsArray,
                    locationNo: _selectedLocationIndex.toString(),
                    measurements: List<String>.from(
                      _selectedMeasurements,
                    ),
                    emitLocDetailsToPolVarWidget:
                        _handleEmitLocDetailsToPolVarWidget),
                SizedBox(
                  height: 300,
                  // child: Text('hi'),

                  child: MeasurementDisplayWidget(measurementDetails),
                )
              ],
            );
          }),
    );
  }

  // ignore: non_constant_identifier_names

  _updateLocationDetailsArray(arr) async {
    print('$arr @ 556');

    if (arr != null && this._workDetails != null) {
      if (this._workDetails!['locations'] == null) {
        this._workDetails!['locations'] = {};
      }
      this._workDetails!['locations'][this._selectedLocationIndex.toString()] =
          arr;

      // await Future.delayed(Duration(seconds: 10));

      // setState(() {
      //   viewStructures = true;
      // });

      // this.userDirections =
      //     'NOW Select Task and then correct structure inside it ';
      // audioCache.play('select_structure.wav');

      // print(this._workDetails);
    }

// this.
  }

  AnimatedOpacity enterLocationDetails() {
    return AnimatedOpacity(
        opacity: _enableEntryOfLocationDetails ? 1.0 : 0.0,
        duration: Duration(milliseconds: 3000),
        child: Visibility(
            visible: _enableEntryOfLocationDetails,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 20,
                    child: TextFormField(
                      maxLength: 3,
                      initialValue: _numberOfLocations.toString(),
                      // controller: TextEditingController(
                      //     text: _numberOfLocations.toString()),
                      decoration: InputDecoration(
                        labelText: 'Number of Locations',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,

                      onEditingComplete: () {},
                      onChanged: (value) {
                        setState(() {
                          _numberOfLocations = int.tryParse(value) ?? 0;

                          if (_numberOfLocations > 0) {
                            this.userDirections =
                                'NOW ENTER FROM AND TO LOCATIONS';
                            audioCache.play('enter_from_to_location_name.wav');
                          }
                          this.steps = this.steps++;
                        });
                      },
                    ),
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 2,
                  color: Colors.blueAccent,
                ),
                Visibility(
                  visible: _numberOfLocations > 0 && _numberOfLocations < 999,
                  child: Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Location',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            initialValue: _toLocation,
                            onChanged: (value) async {
                              String from = ' _fromLocation';
                              String to = '_toLocation';

                              if (_fromLocation != '' && _toLocation != '') {
                                await Future.delayed(Duration(seconds: 3));

                                if (from == _fromLocation &&
                                    to == _toLocation) {
                                  this.userDirections = 'Now Press save ';

                                  audioCache.play('press_save_button.mp3');
                                } else {
                                  from = _fromLocation;
                                  to = _toLocation;
                                }
                              }

                              setState(() {
                                _fromLocation = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'To Location',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            initialValue: _toLocation.toString(),
                            onChanged: (value) {
                              setState(() {
                                _toLocation = value;

                                if (_fromLocation != '' && _toLocation != '') {
                                  this.userDirections = 'Now Press save ';
                                  audioCache.play('press_save_button.mp3');
                                  this.steps = this.steps++; //3
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: (_numberOfLocations > 0 &&
                      _numberOfLocations < 999 &&
                      _fromLocation != '' &&
                      _toLocation != ''),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: saveFromAndTwoLocation,
                        icon: Icon(Icons.save),
                        color: Color.fromARGB(255, 33, 33, 33),
                        tooltip: 'Save Location Details',
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  AnimatedOpacity viewLocationDetails() {
    return AnimatedOpacity(
      opacity: !_enableEntryOfLocationDetails ? 1.0 : 0.0,
      duration: Duration(milliseconds: 3000),
      child: Visibility(
        visible: !_enableEntryOfLocationDetails,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WorkNameWidget(
                  workName:
                      'Number of Locations : ' + _numberOfLocations.toString()),
            ),
            Divider(
              height: 5,
              thickness: 2,
              color: Colors.blueAccent,
            ),
            Row(
              children: [
                Expanded(
                  child: WorkNameWidget(
                      workName: 'From :  $_fromLocation',
                      color: Color(0xFF000080)),

                  // Text('From : ' + _fromLocation),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: WorkNameWidget(
                      workName: 'To  : ' + _toLocation,
                      color: Color(0xFF0080800)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: saveFromAndTwoLocation,
                  icon: Icon(Icons.edit),
                  color: Color.fromARGB(255, 4, 181, 235),
                  tooltip: 'Edit ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility viewLocationList(tasklist1) {
    // return Visibility(child: Text('hi'));

    return Visibility(
      visible: !_enableEntryOfLocationDetails,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          viewTasksAndStructures(tasklist1),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .8,
              child: ListView.builder(
                itemCount: _numberOfLocations,
                // itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => _viewLocationDetail(index),
                    // onDoubleTap: _viewLocationDetail(index),
                    // onDoubleTap: _enterLocationDetails(index),
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      height: 50.0,
                      color: (index == _tappedIndex)
                          ? Colors.green
                          : Colors.grey[300],
                      child: Center(
                        child: Text(
                          'L : ' + (index + 1).toString(),

                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            decoration: TextDecoration.underline,
                          ),
                          // _selectedTemplates.length > index
                          //     ? _selectedTemplates[index]
                          //     : 'Select a template',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Visibility viewTasksAndStructures(tasklist1) {
    print(tasklist1);
    print('taskList abobve  polvar911');
    return Visibility(
      visible: viewStructures,
      child: Expanded(
          flex: 4,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: expansionPanelOfTask(tasklist1),

            // ListView.separated(
            //   itemCount: tasklist1.length,
            //   itemBuilder: (BuildContext context, int index) {
            //     // return Text(tasklist1.toString());

            //     expansionPanelOfTask(tasklist1, index);
            //   },
            //   separatorBuilder: (BuildContext context, int index) {
            //     return Divider();
            //   },
            // ),
          )),
    );
  }

  Visibility viewLocationDetailsX() {
    return Visibility(
        visible: _enableEntryOfLocationDetails,
        child: Text('View111111111111111111111111111111'));

    return Visibility(
      visible: _enableEntryOfLocationDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.blue,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Text Here',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Center(
                      child: Text('Bottom Text Box 1'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Text('Bottom Text Box 2'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.yellow,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // do something
              },
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanelList expansionPanelOfTask(tasklist1, {int index = 0}) {
    var structures = tasklist1[index]['tasks'].toList();

    print(tasklist1);
    print('$tasklist1[index] ar[index] @ 892');

    // return Text('hi');
    return ExpansionPanelList(
      key: GlobalKey(),
      expansionCallback: (int panelIndex, bool isExpanded) {
        print(
            'expansion panel index $panelIndex  and isExpanded is $isExpanded');
        setState(() {
          tasklist1[panelIndex]['isExpanded'] = !isExpanded;
        });
      },
      children: [
        // ExpansionPanel(
        //   headerBuilder: (BuildContext context, bool isExpanded) {
        //     return ListTile(
        //       title: Text(
        //         tasklist1[index]['task_name'].toString(),
        //       ),
        //     );
        //   },
        //   body: Column(children: getStructuresOfTask(structures)),
        //   isExpanded: tasklist1[index]['isExpanded'],
        // ),
      ],
    );
  }

  List<Widget> getStructuresOfTask(List tasks) {
    if (tasks == null || tasks.isEmpty) {
      return [Text('No tasks found.')];
    }

    return tasks.map<Widget>((struct) {
      // print(t);

      var currentItem = measurementDetails.firstWhere(
        (element) => element['locationNo'] == _selectedLocationIndex + 1,
        orElse: () => {},
      );

      /// find structure using structure code for currentItem
      /// find structure using structure code for currentItem

      var str = struct['structure_name'] as String;

      // int taskCount=

      var mstStructureId = struct['structure_code'];

      // print(mstStructureId);

      if (str == null) {
        return Text('Invalid task.');
      }

      return GestureDetector(
        onDoubleTap: () => _showBottomSheet(context),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Wrap(
                    children: [
                      Text(
                        str,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    ],
                  )),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      // Decrement task quantity
                    },
                  ),
                  Text('2'), // Display task quantity
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await this.getMasterEstimateForStructureItem(
                          mstStructureId, 2, struct);
                      // _showBottomSheet(context);

                      // Increment task quantity
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getStructuresOfTask1(tasks) {
    if (tasks == null || tasks.isEmpty) {
      return [Text('error')];
    }

    var a = tasks.map((t) {
      var str = t['structure_name'] as String; // cast to String

      if (str == null) {
        return Text('hi');
      }

      // ignore: unnecessary_cast
      return Card(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(str),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    // item.quantity--;
                  });
                },
              ),
              // Text(item.quantity.toString()),
              Text('2'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    // item.quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      )) as Widget;

      // return Container(child: Text(str));
    }).toList();

    return a;
    // return [Text('1'), Text('2')];
  }

  Future<String> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');
    return Future.value(accessToken);
  }

  Future<void> getMasterEstimateForStructureItem(
      mstStructureId, quantity, struct) async {
    final dio = Dio();

    final url =
        'http://erpuat.kseb.in/api/wrk/getMasterEstimateForStructureItem';

    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
    final body = {
      "strEstimates": {"mst_structure_id": mstStructureId, "quantity": 2}
    };
    final response = await dio.get(
      url,
      options: Options(headers: headers),
      queryParameters: body,
    );

    // print(_taskList);
    print(struct);

    return;

    var t1 =
        _taskList.firstWhere((t) => t['id'] == struct['id'], orElse: () => {});
    print(t1);

    return;

    print(struct);

    print('selectedstructure above');

    // return;

// if (response.statusCode == 200) {
//     final jsonResponse = json.decode(response.body);
//     return jsonResponse['result_data'];
//   } else {
//     throw Exception('Failed to fetch result data');
//   }
    // print(response.headers);

    var re = response.data['result_data'];

    // print(re);
    // print('estimate above');
    if (re == null) {
      print('re below of null  ie no details in master');

      return;
    }

    _masterMaterialEstimate =
        List<Map<String, dynamic>>.from(re['masterMaterialEstimate']);

    // _masterLabEstimateItems =
    //     List<Map<String, dynamic>>.from(re['masterLabEstimateItems']);

    print(_masterMaterialEstimate);

    print('master labour estimate above');

    // print(_masterLabEstimateItems);
    // print(re.keys);

    print(re['masterMaterialEstimate'].length);
    print("re['masterMaterialEstimate'].length");

    for (final mat in re['masterMaterialEstimate']) {
      Map<String, dynamic> ob = {};
      ob['quantity'] = mat['quantity'];
      ob['material_name'] = mat['mst_material']['material_name'];
      ob['material_code'] = mat['mst_material']['material_code'];

      _masterLabEstimateItems.add(ob);

      // print(mat);
    }

    // Map newtask=_tasks.filter

    print(_masterLabEstimateItems);

    print('_master labout estimate  above @1123');

    print(_tasks);

    print('tasks above');

    // return;

    // task['tasks'] = _masterLabEstimateItems;

// _tasks.findWhere(i=>i.taskId==task.id)

    var out = measurementDetails.firstWhere(
      (element) => element['locationNo'] == _selectedLocationIndex + 1,
      orElse: () => {}, // Return null as the default value
    );

    print(_selectedLocationIndex + 1);
    print('locationNo abobe @1134');

    print(out);

    print('out above @ 1128 polvar');

    if (out == {}) {
      measurementDetails.add(struct);
    } else {
      // print(measurementDetails[_selectedLocationIndex]);

      setState(() {
        measurementDetails = List.from(measurementDetails.map((item) {
          if (item['locationNo'] == _selectedLocationIndex) {
            // Create a copy of the original item with specified fields replaced
            return {...item, ...out};
          } else {
            return item;
          }
        }).toList());
      });
    }

    print(measurementDetails);
    print('updated measurement details above polvar 1148');

    // measurementDetails[_selectedLocationIndex][]

    // print(response.data['result_data']);

    // print(response.runtimeType);

    // var tmp = Map.from(response);

    // _measurementsObject = tmp['result_data'];

    // final secureStorage = FlutterSecureStorage();
    // await secureStorage.write(key: 'response_data', value: response.data);
  }

  final employees = [
    {'id': 1, 'name': 'John Doe', 'position': 'Manager'},
    {'id': 2, 'name': 'Jane Smith', 'position': 'Developer'},
    {'id': 3, 'name': 'Bob Johnson', 'position': 'Designer'},
  ];
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                EditableTable<Map<String, dynamic>>(
                  data: _masterLabEstimateItems,
                  headers: ['material_name', 'quantity', 'material_code'],
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () {
                    // do something when Share is tapped
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    // do something when Edit is tapped
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    // do something when Delete is tapped
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _fetchWorkDetails() async {
    try {
      final accessToken1 =
          await storage.getSecureAllStorageDataByKey("access_token");

      final accessToken = accessToken1['access_token'];
      final loginDetails1 =
          await storage.getSecureAllStorageDataByKey('loginDetails');
      final loginDetails = loginDetails1['loginDetails'];

      // final currentSeatDetails = getCurrentSeatDetails(loginDetails);

      // final officeCode = currentSeatDetails['office']['office_code'];
      // final officeId = currentSeatDetails['office_id'];

      final url =
          'http://erpuat.kseb.in/api/wrk/getScheduleDetailsForMeasurement/NORMAL/${widget.workId}/0';

      // print(url);
      final headers = {'Authorization': 'Bearer $accessToken'};
      Response response =
          await Dio().get(url, options: Options(headers: headers));

      if (response.statusCode != 200) {
        return Future.value([-1]);
      }

      if (response.data != null && response.data['result_data'] != null) {
        var res = response.data['result_data'];

        // print(res['wrk_schedule_group_structures']);
        // print('RES ABOVE');
        // print('RES ABOVE');

        return Future.value([res['data']]);
      } else {
        return Future.value([-1]);
      }
    } on Exception catch (e) {
      print("$e  is the error in _fetchWorkDetails()");

      return Future.value([-1]);

      // TODO
    }
  }

  _viewLocationDetail(int index) async {
    print("this is new index of locations $index");

    if (index != -1) {
      /// if a user selectts a location after selecting any other location saving the current datat to storage

      storeMeasurementDetails(measurementDetails);

      print('storeing location details');
    }

    if (_workDetails != null &&
        _workDetails!['locations'] != null &&
        _workDetails!['locations'] != null) {
      // _selectedLocationDetails =
      //     _workDetails!['locations']![_selectedLocationIndex]
      //         as Map<dynamic, dynamic>;

      // _selectedMeasurements = _selectedLocationDetails['measurements'];
    } else {
      _selectedLocationDetails = {};

      _selectedMeasurements = ['test1 ', 'Item2 Qty: 30', 'Item3 Qty: 30'];
    }
    var s = await getMeasurementDetails(
        widget.workId.toString(), _selectedLocationIndex);

    setState(() {
      _previoslySelectedIndex = _selectedLocationIndex;
      _selectedLocationIndex = index;

      _tappedIndex = index;

      print(s);
      print('s aprinted above');
    });
  }

  void saveFromAndTwoLocation() {
    setState(() {
      _enableEntryOfLocationDetails = !_enableEntryOfLocationDetails;

      this.userDirections =
          'Now Select any Location to Starting with  L, Ensure correct location ';
      audioCache.play('select_location.wav');

      this.saveWorkDetails(
          workId: widget.workId.toString(),
          fromLocation: _fromLocation,
          toLocation: _toLocation,
          noOfLocations: _numberOfLocations.toString());
    });
  }
}

_enterLocationDetails(int index) {
  var _selectedLocationIndex = index;
}

class WorkNameWidget extends StatelessWidget {
  final String workName;
  final Color color;
  final String label;

  const WorkNameWidget(
      {Key? key,
      required this.workName,
      this.color = const Color(0xFF800000),
      this.label = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, top: 20),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.9),
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label + workName,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Verdana',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: color),
      ),
    );
  }
}
