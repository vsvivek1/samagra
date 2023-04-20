import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/screens/location_details_widget.dart';

import '../app_theme.dart';
import '../secure_storage/secure_storage.dart';
import 'package:collection/collection.dart';

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
  int _numberOfLocations = 1;
  int _selectedLocationIndex = -1;
  int _previoslySelectedIndex = -1;

  bool _enableEntryOfLocationDetails = true;

  String _fromLocation = '';
  String _toLocation = '';
  int _tappedIndex = -1;

  Map<String, dynamic> _selectedLocationDetails = {};

  List _selectedMeasurements = [];

  Map<dynamic, dynamic>? _workDetails;

  /// save this if this is present
  // List<String> _templates = [

  List<String> _selectedTemplates = [];

  // get workName => this.workName;

  List getStructuresByName(d) {
    List<dynamic> tasks = d;

    List res = [];

    var allTasks =
        tasks.map((t) => t['mst_task']['task_name']).toSet().toList();

    for (int z = 0; z < allTasks.length; z++) {
      var ta = allTasks[z];
      var t2 = tasks
          .where((t) => t['mst_task']['task_name'] == ta)
          .map((t3) => t3['mst_structure']);

      var ob = {};
      ob['task_name'] = ta;
      ob['isExpanded'] = true;
      ob['tasks'] = t2;

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

    var c = getStructuresByName(wrkScheduleGroupStructures).toList();

    return Future.value(c.toList());
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    _updateWorkDetailsOnLoading();
  }

  Future<void> _updateWorkDetailsOnLoading() async {
    final data = await getWorkDetails(widget.workId.toString());

    print(data);

    print('data above');

    // return;

    setState(() {
      if (data != null &&
          data['fromLocation'] != null &&
          data['toLocation'] != null &&
          data['noOfLocations'] != null) {
        _workDetails = data;
        _fromLocation = data['fromLocation']!;
        _toLocation = data['toLocation']!;
        _numberOfLocations = int.parse(data['noOfLocations']!) > 1000
            ? 999
            : int.parse(data['noOfLocations']!);

        if (_workDetails!['locations'] == null) {
          _workDetails!['locations'] ??= {};
        }

        print(_workDetails);

        print('work details abobve $_numberOfLocations');
        _enableEntryOfLocationDetails = false;
      }
    });
  }

  //

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _sheduleBuilder(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData && snapshot.data == -1) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var ar = snapshot.data;

          // ignore: unrelated_type_equality_checks
          if (ar == null || ar == -1) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          int ln = ar.length;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.grey.withOpacity(0.7),
                title: Text('Select Locations and Templates'),
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
                          workName: widget.workName,
                          color: Colors.blue,
                        ),
                        enterLocationDetails(),
                        viewLocationDetails(),
                        Divider(
                          height: 5,
                          thickness: 2,
                          color: Colors.blueAccent,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    // Text(
                                    //   'Your are Progressing with  the Pol Var measurement of  work ${widget.workName}',
                                    //   style: TextStyle(fontSize: 20),
                                    // ),
                                    Divider(
                                      color: Colors.grey,
                                      height: 20,
                                      thickness: 15,
                                    ),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .4,
                                      child: ListView.builder(
                                          // itemCount: _numberOfLocations,
                                          itemCount: 1,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return LocationDetailsWidget(
                                              locationDetails: {},
                                              updateLocationDetailsArray:
                                                  _updateLocationDetailsArray,
                                              locationNo: _selectedLocationIndex
                                                  .toString(),
                                              measurements: List<String>.from(
                                                  _selectedMeasurements),
                                            );
                                          }),
                                    )
                                  ]),
                            )
                          ],
                        ),
                        Divider(color: Colors.amber, thickness: 10),
                        SizedBox(height: 50),
                        viewLocationList(ar),
                        SizedBox(height: 2000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  _updateLocationDetailsArray(arr) {
    if (arr != null) {
      this._workDetails!['locations'][this._selectedLocationIndex.toString()] =
          arr;

      print(this._workDetails);
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
                    onChanged: (value) {
                      setState(() {
                        _numberOfLocations = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 2,
                  color: Colors.blueAccent,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'From Location',
                          border: OutlineInputBorder(),
                        ),
                        child: TextFormField(
                          initialValue: _toLocation,
                          onChanged: (value) {
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
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: saveFromAndTwoLocation,
                      icon: Icon(Icons.save),
                      color: Colors.grey[900],
                      tooltip: 'Save Location Details',
                    ),
                  ],
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

  Visibility viewLocationList(ar) {
    return Visibility(
      visible: !_enableEntryOfLocationDetails,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              flex: 4,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: ListView.separated(
                  itemCount: ar.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TasksList(ar, index);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              )),
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

  ExpansionPanelList TasksList(ar, int index) {
    var tasks = ar[index]['tasks'].toList();

    // return Text('hi');
    return ExpansionPanelList(
      expansionCallback: (int panelIndex, bool isExpanded) {
        setState(() {
          ar[panelIndex]['isExpanded'] = !isExpanded;

          //
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                ar[index]['task_name'].toString(),
              ),
            );
          },
          body: Column(children: getTasksItems(tasks)),
          isExpanded: ar[index]['isExpanded'],
        ),
      ],
    );
  }

  List<Widget> getTasksItems(List tasks) {
    if (tasks == null || tasks.isEmpty) {
      return [Text('No tasks found.')];
    }

    return tasks.map<Widget>((t) {
      var str = t['structure_name'] as String;

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
                    onPressed: () {
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

  List<Widget> getTasksItems1(tasks) {
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: [
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
          'http://erpuat.kseb.in/api/wrk/getScheduleDetailsForMeasurement/NORMAL/47777/0';
      final headers = {'Authorization': 'Bearer $accessToken'};
      Response response =
          await Dio().get(url, options: Options(headers: headers));

      if (response.statusCode != 200) {
        return Future.value([-1]);
      }

      if (response.data != null && response.data['result_data'] != null) {
        var res = response.data['result_data'];

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

  _viewLocationDetail(int index) {
    print("this is new index of locations $index");
    setState(() {
      _previoslySelectedIndex = _selectedLocationIndex;
      _selectedLocationIndex = index;

      _tappedIndex = index;

      if (_workDetails != null &&
          _workDetails!['locations'] != null &&
          _workDetails!['locations']!.null) {
        _selectedLocationDetails =
            _workDetails!['locations']![_selectedLocationIndex]
                as Map<dynamic, dynamic>;

        _selectedMeasurements = _selectedLocationDetails['measurements'];
      } else {
        _selectedLocationDetails = {};

        _selectedMeasurements = ['test1 ', 'Item2 Qty: 30', 'Item3 Qty: 30'];
      }
    });
  }

  void saveFromAndTwoLocation() {
    setState(() {
      _enableEntryOfLocationDetails = !_enableEntryOfLocationDetails;

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
