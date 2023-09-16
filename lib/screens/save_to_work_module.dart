import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'package:samagra/screens/send_to_mail.dart';
import 'package:samagra/screens/set_access_token_to_dio.dart';
import 'package:samagra/secure_storage/common_functions.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'measurement_data_to_work_module.dart';
import '../common.dart';

import 'package:http/http.dart' as http;

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
    polVarMeasurementObject = widget.dataFromPreviousScreen as Map;
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

        dataToSend['office_id'] = await getOfficeId();
        dataToSend['role_id'] = await getUserRoleId();
        dataToSend['part_or_final'] = 'FINAL';
        dataToSend['polevar_data'] = jsonEncode(polvar_data);

        dio = await setAccessTockenToDio(dio);

        dataToSend.forEach((key, value) {
          print("KEYstwm 234 ${key.toString()} -> ${value.toString()}");

          // if (key == 'taskmeasurements') {
          //   dataToSend[key].forEach((key, value) => {print("TASK  ${value} ")});
          //   print("TASK  ${value.runtimeType}");
          // }
        });

        // gmailMe(dataToSend);

        // return;

        // debugger(when: true);
        // return;

        // print('stop');
        // FormData formData = FormData.fromMap(dataToSend);

        FormData formData = FormData();

        // Iterate through the dataToSend map and add each key-value pair as a field
        dataToSend.forEach((key, value) {
          formData.fields.add(MapEntry(key.toString(), value.toString()));
        });

        // print('here2');
        setState(() {
          _isSubmitting = false;
          _apiResult = 'Success';
        });

        print(formData.fields);
        // var response = await dio.post(
        //   'http://erpuat.kseb.in/api/wrk/saveMeasurementWithPolevar',
        //   // data: dataToSend,
        //   data: formData,
        // );

        final String url =
            'http://erpuat.kseb.in/api/wrk/saveMeasurementWithPolevar';

        var request = http.MultipartRequest('POST', Uri.parse(url));

        String token = await getAccessToken();

        print('$token');
        request.headers['Authorization'] = 'Bearer $token';

        // final http.Response response = await http.post(
        //   Uri.parse(url),
        //   body: formData,
        // );

        final response = await request.send();

        // print(response.data);

        if (response.statusCode == 200) {
          // print(response);
          final responseData = await response.stream.bytesToString();
          print('Response: $responseData');
          setState(() {
            _isSubmitting = false;
            _apiResult = 'Success';
          });
        } else {
          setState(() {
            print(response);

            _isSubmitting = false;
            _apiResult = 'Failed';
          });
        }
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
