import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../secure_storage/secure_storage.dart';

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

  Iterable<Map> getStructuresByName(d) {
    var e = [];
    var ids = [];

    print(d);
    print('d above');

    d.forEach((grp) {
      var e1 = (grp as Map)['mst_task'];

      if (!e.contains(e1)) {
        e.add(e1);
      }
    });

    // if (!ids.contains(ids)) {
    //       e.add(ids['id']);
    //     }
    //   });

    var g2 = e.map((g) {
      // print(g);
      // print('g above');

      var a = {};

      var ob =
          d.where((element) => element['mst_task']['id'] == g['id']).toList();

      a['task_name'] = g['task_name'];
      a['structures'] = [];
      ob.forEach((ob2) {
        a['structures'].add(ob2['mst_structure']);
      });

      return a;
    });

    print('g2 below');
    print(g2);

    print('g2 above');

    return g2;
  }

  Future _sheduleBuilder() async {
    var workDetails = await _fetchWorkDetails(); //.then((workDetails) {

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
          var ar = snapshot.data;
          print(ar.runtimeType);
          // print(snapshot.data);

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
                          itemCount: ar.length,
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
                                      Text(ar[index]),
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
      return Future.value(['hi']);
    }
  }

  void saveFromAndTwoLocation() {
    print('pressed');
  }
}
