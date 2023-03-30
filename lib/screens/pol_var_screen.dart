import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../secure_storage/secure_storage.dart';
import 'package:collection/collection.dart';

class PolVarScreen extends StatefulWidget {
  @override
  final int workId;

  PolVarScreen({Key? key, required this.workId}) : super(key: key) {
    print("this is workid $workId");
  }

  _PolVarScreenState createState() => _PolVarScreenState();
}

class _PolVarScreenState extends State<PolVarScreen> {
  final storage = SecureStorage();
  int _numberOfLocations = 1;
  // List<String> _templates = [

  List<dynamic> _templates = [
    {
      "task_name":
          "ReconductoringLT OH 5 wire line with LT three phase ABC(CIRCUIT KM)",
      "structures": [
        {"id": 3862, "structure_name": "COIL EARTH", "structure_code": 1113},
        {
          "id": 3870,
          "structure_name": "ADD TRANSPORT TRIP",
          "structure_code": 7207
        }
      ]
    },
    {
      "task_name": "Another Task",
      "structures": [
        {
          "id": 1234,
          "structure_name": "Some Structure",
          "structure_code": 5678
        },
        {
          "id": 5678,
          "structure_name": "Another Structure",
          "structure_code": 9101
        }
      ]
    }
  ];

  List<String> _selectedTemplates = [];

  List getStructuresByName(d) {
    List<dynamic> tasks = d;

    // print(tasks);

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
      ob['tasks'] = t2;

      res.add(ob);

      // print(t2);

      // var x = t2.map((a) => a.mst_structure);

      // print(x);

      // print('t2 above');
    }

    return res;
    print(res);
    print('  resall taks above');

    List<Map<String, dynamic>> tasks1 = [
      {
        'task_name': 'Task 1',
        'id': 1,
        'structures': ['Structure 1', 'Structure 2', 'Structure 3']
      },
      {
        'task_name': 'Task 2',
        'id': 2,
        'structures': ['Structure 4', 'Structure 5']
      },
      {
        'task_name': 'Task 1',
        'id': 3,
        'structures': ['Structure 6', 'Structure 7']
      }
    ];

    return tasks1;

    Map<String, List<Map<String, dynamic>>> groupedTasks = {};

    tasks.forEach((task) {
      String taskName = task['task_name'];

      if (groupedTasks.containsKey(taskName)) {
        groupedTasks[taskName]!.add(task);
      } else {
        groupedTasks[taskName] = [task];
      }
    });

    List<Map<String, dynamic>> result = [];

    groupedTasks.forEach((taskName, tasks) {
      List<dynamic> structures = [];
      int id = -1;

      tasks.forEach((task) {
        structures.addAll(task['structures']);
        id = task['id'];
      });

      result.add({'task_name': taskName, 'id': id, 'structures': structures});
    });

    print(result);

    return result;
  }

  // Iterable<Map> getStructuresByName1(d) {
  //   var e = Set();
  //   var ids = [];

  //   // print(d);
  //   // print('d above');

  //   var groupedTasks = groupBy(d, (task) => task);

  //   List<Map<String, dynamic>> result = [];

  //   // var tasks = d;

  //   groupedTasks.forEach((taskName, tasks) {
  //     List<dynamic> structures = [];
  //     int id;
  //     tasks.forEach((task) {
  //       structures.addAll(task!.structures);
  //       id = task.id;
  //     });

  //     result.add({'task_name': taskName, 'id': id, 'structures': structures});
  //   });

  //   d.forEach((grp) {
  //     var e1 = (grp as Map)['mst_task'];

  //     bool containsTaskName = e.length != 0 &&
  //         e.any((element) => element.task_name == e1.task_name);

  //     print('this is $containsTaskName');
  //     // if (!containsTaskName) {
  //     //   e.add(e1);
  //     // }
  //   });

  //   var g2 = e.map((g) {
  //     // print(g);
  //     // print('g above');

  //     var a = {};

  //     var ob =
  //         d.where((element) => element['mst_task']['id'] == g['id']).toList();

  //     a['task_name'] = g['task_name'];
  //     a['structures'] = [];

  //     a["isExpanded"] = false;
  //     ob.forEach((ob2) {
  //       a['structures'].add(ob2['mst_structure']);
  //     });

  //     return a;
  //   });

  //   print('g2 below');
  //   print(g2);

  //   print('g2 above');

  //   return g2;
  // }

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
    // print(res);
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

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

          if (ar == null) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          int ln = ar.length;
          print("this is len $ln");
          print(ar.runtimeType);

          print(ar[0]);
          print('snapsho data below');
          // print(snapshot.data);

          // print(ar[24]);

          // print('24 above');

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.grey.withOpacity(0.7),
              title: Text('Select Locations and Templates'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
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
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'From Location',
                          border: OutlineInputBorder(),
                        ),
                        child: TextField(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'To Location',
                          border: OutlineInputBorder(),
                        ),
                        child: TextField(),
                      ),
                    ),
                    IconButton(
                      onPressed: saveFromAndTwoLocation,
                      icon: Icon(Icons.save),
                      color: Colors.grey,
                    )
                  ],
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GridView.builder(
                          itemCount: ln,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            bool isExpanded =
                                true; //_templates[index]['isExpanded'];
                            // List<Map<String, dynamic>> tasks = _templates[index];
                            //['tasks'];

                            // 919656264570

                            // var cur = _templates[index];
                            // var task = cur['task_name'];

                            // print(task);
                            // print('task above');
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  // _templates[index]['isExpanded'] = !isExpanded;

                                  // print("this is expanded $task ");

                                  // _selectedTemplates.add(_templates[index]);
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                color: Colors.grey[300],
                                child: Center(
                                  child: ListView(
                                    children: [
                                      Text(ar[index]['task_name'].toString()),
                                      IconButton(
                                        icon: Icon(Icons.expand_less, size: 30),
                                        onPressed: () {
                                          setState(() {
                                            // _templates[index]['isExpanded'] =
                                            //     !isExpanded;
                                          });
                                        },
                                        // icon: isExpanded
                                        //     ? Icon(Icons.expand_less, size: 30)
                                        //     : Icon(Icons.expand_more, size: 30),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: _numberOfLocations,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.all(8.0),
                              height: 50.0,
                              color: Colors.grey[300],
                              child: Center(
                                child: Text('hi'
                                    // _selectedTemplates.length > index
                                    //     ? _selectedTemplates[index]
                                    //     : 'Select a template',
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
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
      final response = await Dio().get(url, options: Options(headers: headers));

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

  void saveFromAndTwoLocation() {
    print('pressed');
  }
}
