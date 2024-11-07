import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/search_labour.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

class LabourEntry extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  Function reflectQuantityDetails;
  Map<int, Map<dynamic, dynamic>> estimatedQuantityOfLabour;
  var measurementDetails;
  var taskId;
  var structureId;
  var mst_scheme_id;

  LabourEntry({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfLabour,
    required this.measurementDetails,
    required this.taskId,
    required this.structureId,
    required this.mst_scheme_id,
  });

  @override
  _LabourEntryState createState() => _LabourEntryState();
}

class _LabourEntryState extends State<LabourEntry> {
  var labour = [];
  String selectedLabour = '1'; // Set a valid initial value
  String quantity = '';
  List labourMaster = [];
  String userText = '';
  List selectedLabourItems = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLabourMasterData(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!(snapshot.hasData)) {
          return Center(
            widthFactor: 3,
            heightFactor: 3,
            child: SpinKitFadingCube(color: Colors.blue), // Use your color here
          );
        }
        labourMaster = snapshot.data;
        return Container(
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(spreadRadius: 2, blurRadius: 2)],
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  colors: [Colors.grey, Colors.white70, Colors.grey])),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  "Labour Entries",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SearchLabour(
                onNewLabourAdded: (item) => {onNewLabourAdded(item)},
                labourMaster: labourMaster,
                selectedLabourItems: selectedLabourItems,
                selectedLabour: [],
              ),
              Divider(color: Colors.red),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFDDE1),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0.112, 0.922],
                    transform: GradientRotation(109.6 * 3.14 / 180),
                  ),
                ),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .9,
                  height: MediaQuery.sizeOf(context).height * .5,
                  child: Column(
                    children: [
                      Expanded(
                          child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemBuilder: itemBuilder,
                              separatorBuilder: separatorBuilder,
                              itemCount: selectedLabourItems.length)),
                      ElevatedButton(
                          onPressed: (() {
                            addExtraLabourToMeasurements();
                          }),
                          child: Text('Save'))
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List<dynamic>> getLabourMasterData() async {
    if (labourMaster.isNotEmpty) {
      return labourMaster;
    }

    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final dio = Dio();
    final url = '${config.liveServiceUrl}wrk/getLabourMaster/0';
    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    String accessToken = await getAccessToken();
    setDioAccessokenAndApiKey(dio, accessToken, config);

    final response = await dio.get(url, options: Options(headers: headers));
    return response.data['result_data']['labourMaster'];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  addExtraLabourToMeasurements() {
    Map result = {};

    result['selectedLabour'] = selectedLabourItems;
    result['taskId'] = widget.taskId;
    result['structureId'] = widget.structureId;

    Navigator.pop(context, result);
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Divider(color: Colors.red);
  }

  Widget buildIntegerInputField({
    String labelText = '',
    required Function(String) onChanged,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget? itemBuilder(BuildContext context, int index) {
    return ListTile(
      title: Text(selectedLabourItems[index]['labour_name']),
      subtitle: Column(
        children: [
          buildIntegerInputField(
            labelText: 'Enter quantity',
            onChanged: (value) {
              selectedLabourItems[index]['quantity'] = value;
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Text(
              style: TextStyle(
                color: ((selectedLabourItems[index]['availability'] ?? 0) > 0)
                    ? Colors.green
                    : Colors.red,
                fontSize: 13,
              ),
              'Availability: ${selectedLabourItems[index]['availability']}'),
        ],
      ),
      trailing: Column(
        children: [
          IconButton(
              onPressed: (() {
                _removeSelectedItem(index);
              }),
              icon: Icon(Icons.delete)),
        ],
      ),
    );
  }

  Future getLabourAvailability(labourId) async {
    Map userDetails = await getUserLoginDetailsMap();
    var officeId = userDetails['seat_details']['office_id'] ?? -1;

    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final dio = Dio();
    final url =
        '${config.liveServiceUrl}wrk/getLabourAvailability/${officeId}/${widget.mst_scheme_id}/${labourId}';
    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    String accessToken = await getAccessToken();
    setDioAccessokenAndApiKey(dio, accessToken, config);

    var response = await dio.get(url).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to retrieve data')));
      return -1;
    });

    if (response.statusCode == 200 && response.data['result_flag'] == 1) {
      return response.data['result_data']['availability'] ?? 0;
    } else {
      return 0;
    }
  }

  onNewLabourAdded(data) async {
    var availability = await getLabourAvailability(data['id']);
    var labour = selectedLabourItems.firstWhere(
      (element) => element['id'] == data['id'],
      orElse: () => {},
    );
    if (labour.isEmpty || availability == 0) {
      labour['availability'] = 0;
    } else {
      labour['availability'] = availability;
    }

    if (selectedLabourItems.length > 0) {
      Future.microtask(() {
        setState(() {});
      });
    }
  }

  void _removeSelectedItem(int index) {
    if (selectedLabourItems.length > index && index > -1) {
      selectedLabourItems.removeAt(index);
    }
  }
}
