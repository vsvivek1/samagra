import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/tree_cutting_walk.dart';
import 'package:samagra/secure_storage/secure_storage.dart';

class TreeCuttingCompensation extends StatefulWidget {
  @override
  _TreeCuttingCompensationState createState() =>
      _TreeCuttingCompensationState();
}

class _TreeCuttingCompensationState extends State<TreeCuttingCompensation> {
  List<Work> _workList = [];
  String selectedWork = '';
  String currentStatus = '';
  bool isLoading = true;
  final storage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchWorkList();
  }

  Future _fetchWorkList() async {
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
        var res = response.data['result_data']['schGrpList']
            .map((data) => Work.fromMap(data))
            .toList();

        _workList = List<Work>.from(res);

        setState(() {}); // Trigger a rebuild after fetching the work list
        // _workList = List.from(res);

        setState(() {
          isLoading = false;
        });

        // print(res);
        // this.callApiAndSaveLabourGroupMasterInSecureStorage();

        return;
      } else {
        _workList = [];
        setState(() {
          isLoading = false;
        });

        print('some error');
        // return [];
      }
    } on Exception catch (e) {
      // setState(() {
      //   isLoading = false;
      // });

// var wrk=Work(workDetail:{'test':0})
      return; //Future.value(k);

      print(e); // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade200,
          shadowColor: Colors.green.shade900,
          title: Text('TREE CUTTING COMPENSATION'),
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Container(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('Select Work',
                            style: TextStyle(
                              color: Colors.green[400],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _workList.length,
                          itemBuilder: (context, index) {
                            Work work = _workList[index];
                            bool isRightSide = index % 2 ==
                                0; // Check if the index is even or odd

                            return Column(
                              children: [
                                ListTile(
                                  trailing: IconButton(
                                    onPressed: () => {},
                                    icon: RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(
                                        isRightSide
                                            ? Icons.arrow_forward
                                            : Icons
                                                .arrow_back, // Display arrow icons based on the side
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  selected:
                                      selectedWork == work.workDetail.workName,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[200],
                                    radius: 15,
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(1),
                                  onTap: () {
                                    setState(() {
                                      selectedWork = work.workDetail.workName;
                                    });
                                  },
                                  title: Text(work.workDetail.workName),
                                  tileColor:
                                      selectedWork == work.workDetail.workName
                                          ? Colors.green.shade100
                                          : null,
                                ),
                                Divider(
                                  height: 5,
                                  color: Colors.green[400],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      if (selectedWork.isNotEmpty)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TreeCuttingWalk()),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Tree Cutting Survey',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Spacer(),
                                  Hero(
                                    tag: 'myHero',
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(Icons.forest_rounded),
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Perform action for Tree Cutting Notice Preparation
                              },
                              child: Text(
                                'Tree Cutting Notice Preparation',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Perform action for Tree Cutting Authorization
                              },
                              child: Text(
                                'Tree Cutting Authorization',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Perform action for Tree Cutting Final measurement
                              },
                              child: Text(
                                'Tree Cutting Final measurement',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade900,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: _getStatusColor(currentStatus),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Current Status: $currentStatus',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Pending') {
      return Colors.orange;
    } else if (status == 'Approved') {
      return Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}

class Work {
  final WorkDetail workDetail;

  Work({required this.workDetail});

  factory Work.fromMap(Map<String, dynamic> map) {
    return Work(
      workDetail: WorkDetail.fromMap(map['wrk_work_detail']),
    );
  }
}

class WorkDetail {
  final String workName;

  WorkDetail({required this.workName});

  factory WorkDetail.fromMap(Map<String, dynamic> map) {
    return WorkDetail(
      workName: map['workName'],
    );
  }
}
