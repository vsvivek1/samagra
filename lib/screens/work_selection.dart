import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/internet_connectivity.dart';

import '../secure_storage/secure_storage.dart';
import 'package:samagra/secure_storage/common_functions.dart';

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
    return FutureBuilder(
      future: _fetchWorkListList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final workListList = snapshot.data;

          // p(WorkListList);
          p(workListList.runtimeType);

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
          return CircularProgressIndicator();
        }
      },
    );
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
    final response = await Dio().get(url, options: Options(headers: headers));

    //write code here to action for no work code error code -1 display error etc
    p(response.data['result_data']);

    if (response.data != null &&
        response.data['result_data'] != null &&
        response.data['result_data']['schGrpList'] != null) {
      var res = response.data['result_data']['schGrpList'];

      p(res);
      return res;
    } else {
      p('some error');
      return [];
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

  @override
  void initState() {
    _filteredItems = List.from(widget.schGrpList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
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
                              .where((item) => item['wrk_work_detail']
                                      ['work_name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
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
                    return Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      child: GridTile(
                        header: Text(sl.toString()),
                        child: Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Text(item['wrk_work_detail']['work_name']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
