import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'measurement_data_to_work_module.dart';

class SaveToWorkModule extends StatefulWidget {
  final Map dataFromPreviousScreen;

  SaveToWorkModule({required this.dataFromPreviousScreen});

  @override
  _SaveToWorkModuleState createState() => _SaveToWorkModuleState();
}

class _SaveToWorkModuleState extends State<SaveToWorkModule> {
  final _formKey = GlobalKey<FormState>();
  late MeasurementDataToWorkModule _measurementDataToWorkModule;
  late Map polVarMeasurementObject;
  bool _isSubmitting = false;
  String _apiResult = '';
  var workId;
  var polvar_data;

  @override
  void initState() {
    super.initState();
    workId = widget.dataFromPreviousScreen['workId'];
    polvar_data = widget.dataFromPreviousScreen['polevar_data'];
    initialiseMeasurementObject().then((_) {
      // print('MDATA ${_measurementDataToWorkModule.toMap()}');
    });
    polVarMeasurementObject = widget.dataFromPreviousScreen;
  }

  initialiseMeasurementObject() async {
    _measurementDataToWorkModule = MeasurementDataToWorkModule(
      workId: workId.toString(),
      is_premeasurement: false,
      part_or_final: true,
      measurement_set_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      commencement_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      completion_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      plg_work_id: workId,
      taskMeasurements: [],
    );

    _measurementDataToWorkModule.seat_id = await getSeatId();

    await _measurementDataToWorkModule
        .fetchScheduleDetailsAndSetParams(
            workId.toString(), widget.dataFromPreviousScreen)
        .then(
      (value) {
        print("VALUE line 60 stwm ${value.toString()}");
      },
    );

    print('MDATA stwm 64 ${_measurementDataToWorkModule.toMap()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save to Work Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CheckboxListTile(
                title: Text('Is this a  Premeasurement ?'),
                value: _measurementDataToWorkModule.is_premeasurement,
                onChanged: (newValue) {
                  setState(() {
                    _measurementDataToWorkModule.is_premeasurement = newValue!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Is This a  Part Measurement ? '),
                value: _measurementDataToWorkModule.part_or_final,
                onChanged: (newValue) {
                  setState(() {
                    _measurementDataToWorkModule.part_or_final = newValue!;
                  });
                },
              ),
              ListTile(
                title: Text('Date of Commencement of Work'),
                subtitle: Text(
                    _measurementDataToWorkModule.commencement_date.toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(
                      context,
                      _measurementDataToWorkModule.commencement_date
                          as DateTime, (newDate) {
                    setState(() {
                      _measurementDataToWorkModule.commencement_date =
                          newDate as String?;
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text('Date of Completion of Work'),
                subtitle: Text(
                    _measurementDataToWorkModule.completion_date.toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context,
                      _measurementDataToWorkModule.completion_date as DateTime,
                      (newDate) {
                    setState(() {
                      _measurementDataToWorkModule.completion_date =
                          newDate as String?;
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text('Measurement Set Date'),
                subtitle: Text(_measurementDataToWorkModule.measurement_set_date
                    .toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(
                      context,
                      _measurementDataToWorkModule.measurement_set_date
                          as DateTime, (newDate) {
                    setState(() {
                      _measurementDataToWorkModule.measurement_set_date =
                          newDate as String?;
                    });
                  }),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous screen.
                    },
                    child: Text('Back'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text('Submit to Work Module'),
                  ),
                ],
              ),
              if (_apiResult.isNotEmpty) SizedBox(height: 16),
              if (_apiResult.isNotEmpty)
                Text(
                  _apiResult,
                  style: TextStyle(
                      color:
                          _apiResult == 'Success' ? Colors.green : Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate);
    }
  }

  Future<String> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');

    return Future.value(accessToken);
  }

  void _submitForm() async {
    String token = await getAccessToken();
    // widget.dataFromPreviousScreen.forEach((key, value) {
    //   print("$key --> $value");
    // });

    // return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _apiResult = '';
      });
      _formKey.currentState!.save();

      // Perform the POST request using Dio
      Dio dio = Dio();
      try {
        var dataToSend = _measurementDataToWorkModule.toMap();

        dataToSend['office_id'] = (await getOfficeId()).toString();
        dataToSend['role_id'] = (await getUserRoleId()).toString();
        dataToSend['part_or_final'] = 'FINAL';
        // dataToSend['polevar_data'] = jsonEncode(polvar_data);
        dataToSend['polevar_data'] = jsonEncode(polvar_data);

        // return;
        // dio = await setAccessTockenToDio(dio);

        // dataToSend.forEach((key, value) {
        //   print("KEYstwm 234 ${key.toString()} -> ${value.toString()}");

        //   // if (key == 'taskmeasurements') {
        //   //   dataToSend[key].forEach((key, value) => {print("TASK  ${value} ")});
        //   //   print("TASK  ${value.runtimeType}");
        //   // }
        // });

        // gmailMe(dataToSend);

        // return;

        // debugger(when: true);
        // return;

        // print('stop');
        // FormData formData = FormData.fromMap(dataToSend);

        FormData formData = FormData();

        // // Iterate through the dataToSend map and add each key-value pair as a field
        // dataToSend.forEach((key, value) {
        //   formData.fields.add(MapEntry(key.toString(), value.toString()));
        // });

        // print('here2');
        setState(() {
          _isSubmitting = false;
          _apiResult = 'Success';
        });
        // return;
        var headers = {
          'Authorization': 'Bearer $token',
          'Cookie': 'laravel_session=8XnfA1lbGXvJZWBf8sDwwTWs1YAaekeM0jo0OTXk',
          'Content-Type': 'application/json',
        };
        // var data = FormData.fromMap({
        //   'wrk_measurement_set_id': '',
        //   'user_id': '21701',
        //   'seat_id': '23752',
        //   'plg_work_id': '43181',
        //   'wrk_schedule_group_id': '26353',
        //   'is_premeasurement': 'false',
        //   'part_or_final': 'FINAL',
        //   'measurement_set_date': '2023-09-18',
        //   'commencement_date': '2023-09-17',
        //   'completion_date': '2023-09-17',
        //   'taskMeasurements':
        //       '{1216: {quantity: 1, mst_task_id: 1216, plg_work_id: 26353}, 1219: {quantity: 1, mst_task_id: 1219, plg_work_id: 26353}}',
        //   'structureMeasurements':
        //       '{3524: {mst_structure_id: 3524, mst_task_id: 1216, wrk_schedule_group_structure_id: null}, 3525: {mst_structure_id: 3525, mst_task_id: 1219, wrk_schedule_group_structure_id: null}}',
        //   'materialMeasurements': '{}',
        //   'labourMeasurements':
        //       '{160765: {wrk_execution_schedule_id: 43481, wrk_execution_labour_schedule_id: 160765, mst_labour_id: 113, labour_name: Giving one single phase WP service connection, as per standards, incl. conveyance of materials., labour_code: 251, mst_uom_id: 74, uom_code: No, rate: 1153.00, quantity: 1}, 160766: {wrk_execution_schedule_id: 43481, wrk_execution_labour_schedule_id: 160766, mst_labour_id: 114, labour_name: Giving one three phase   WP service connection (upto 10kW) as per standards, incl. conveyance of materials., labour_code: 252, mst_uom_id: 74, uom_code: No, rate: 1715.00, quantity: 1}}',
        //   'materialTakenBackMeasurements': '{}',
        //   'polevar_data': '{}',
        //   'office_id': '1704',
        //   'role_id': '1'
        // });

//         dataToSend.forEach((key, value) {
//           // dataToSend[key] = value.toString();

//           String type = dataToSend[key].runtimeType.toString();

//           if (dataToSend[key] == null) {
//             dataToSend[key] = 'Null';
//           }

// // if(type==null)
//           if (key == 'labourMeasurements') {
//             return;
//           }

//           // print(key);

//           type.contains("Map")
//               ? dataToSend[key] = jsonEncode(dataToSend[key])
//               : dataToSend[key] = dataToSend[key].toString();

//           print("$key-->> ${dataToSend[key].runtimeType}");
//         });

        // dataToSend.forEach((key, value) {
        //   print(key);
        //   if (key == 'labourMeasurements') {
        //     print('here');
        //     dataToSend[key] = {};

        //     print('lab ${dataToSend[key]}');
        //   }
        //   if (value == null) {
        //     dataToSend[key] = 'Null';
        //   } else if (value is Map || value is List) {
        //     try {
        //       jsonEncode(value);
        //       print('The value is JSON-encodable.');
        //     } catch (e) {
        //       print(value);
        //       print(' $key The value is not JSON-encodable: $e');
        //     }
        //     ;
        //   } else {
        //     dataToSend[key] = value.toString();
        //   }
        //   print("$key-->> ${dataToSend[key].runtimeType}");
        // });

        // return;
        // var data = 0;

        // FormData data = FormData.fromMap(dataToSend);

        // debugger(when: true);

        FormData data = FormData();

        // Iterate through the structured data and add it to the FormData object
        dataToSend.forEach((key, value) {
          if (value.runtimeType != String) {
            value = value.toString();
          }
          print("$key  ->> $value");

          // data.fields.add(MapEntry(key, value.toString()));
        });

        // try {
        //   // String jsonData = json.encode(dataToSend);
        //   // Make the Dio request here
        // } catch (e) {
        //   print('Error encoding JSON: $e');
        // }
        // return;
        var dio = Dio();
        var response = await dio.request(
          'http://erpuat.kseb.in/api/wrk/saveMeasurementWithPolevar',
          options: Options(
            method: 'POST',
            headers: headers,
          ),
          // data: data,
          data: dataToSend,
        );

        print("error ${response.data}");
        if (response.statusCode == 200) {
          if (response.data['result_flag'] == -1) {
            final snackBar = SnackBar(
              content: Text('Error '),
              duration: Duration(
                  seconds: 3), // How long the snackBar will be displayed
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {
                  // Code to execute when 'Close' is pressed
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          print(json.encode(response.data));
        } else {
          print(response.statusMessage);
        }

        ///here ////

        // // print('$token');
        // request.headers['Authorization'] = 'Bearer $token';

        // dataToSend.forEach((key, value) {
        //   // print("$key");

        //   // request.fields[key] = value ?? 'null';
        // });

        // dataToSend.forEach((key, value) {
        //   print("$key --> $value");
        //   request.fields[key] = value.toString() ?? 'null';
        // });

        // request.fields.forEach((key, value) {
        //   print("$key --> $value");
        //   // request.fields[key] = value.toString() ?? 'null';
        // });

        // final http.Response response = await http.post(
        //   Uri.parse(url),
        //   body: formData,
        // );

        // print(request.url);
        // print(request.headers);
        // print(request.method);

        // final response = await request.send();

        // print(response.data);

        // if (response.statusCode == 200) {
        //   // print(response);
        //   final responseData = await response.stream.bytesToString();
        //   print('Response: $responseData');
        //   setState(() {
        //     _isSubmitting = false;
        //     _apiResult = 'Success';
        //   });
        // } else {
        //   setState(() {
        //     print(response);

        //     _isSubmitting = false;
        //     _apiResult = 'Failed';
        //   });
        // }
      } catch (e) {
        print(e);
        setState(() {
          _isSubmitting = false;
          _apiResult = 'Error: $e';
        });
      }
    }
  }
}
