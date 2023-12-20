import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'package:samagra/screens/server_message_widget.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/screens/work_name_widget.dart';
import 'package:samagra/screens/work_selection.dart';
import 'measurement_data_to_work_module.dart';

import 'package:samagra/environmental_config.dart';

EnvironmentConfig config = EnvironmentConfig.fromEnvFile();

class SaveToWorkModule extends StatefulWidget {
  final Map dataFromPreviousScreen;
  int workId; // Initialize these fields
  String workScheduleGroupId;

  String workName = '';

  SaveToWorkModule({
    required this.dataFromPreviousScreen,
    required this.workId, // Initialize this field in the constructor
    required this.workScheduleGroupId,
    required workName, // Initialize this field in the constructor
  });

  @override
  _SaveToWorkModuleState createState() => _SaveToWorkModuleState();
}

class _SaveToWorkModuleState extends State<SaveToWorkModule>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late MeasurementDataToWorkModule _measurementDataToWorkModule;
  late Map polVarMeasurementObject;
  bool _isSubmitting = false;
  String _apiResult = '';
  // var workId;
  var polvar_data;
  late AnimationController _animationController;

  var _apiResultFlag = 1;
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this, // Use 'this' as the TickerProvider
      duration: Duration(milliseconds: 500),
    );
    _animationController.forward();
    // workId = widget.dataFromPreviousScreen['workId'];
    // workId = widget.wo
    polvar_data = widget.dataFromPreviousScreen['polevar_data'];
    initialiseMeasurementObject().then((_) {
      // print('MDATA ${_measurementDataToWorkModule.toMap()}');
    });
    polVarMeasurementObject = widget.dataFromPreviousScreen;
  }

  initialiseMeasurementObject() async {
    _measurementDataToWorkModule = MeasurementDataToWorkModule(
      wrk_schedule_group_id: widget.workScheduleGroupId,
      workScheduleGroupId: widget.workScheduleGroupId,
      workId: widget.workId.toString(),
      is_premeasurement: false,
      part_or_final: true,
      measurement_set_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      commencement_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      completion_date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      plg_work_id: widget.workId,
      taskMeasurements: [],
    );

    _measurementDataToWorkModule.seat_id = await getSeatId();

    await _measurementDataToWorkModule
        .fetchScheduleDetailsAndSetParams(
            widget.workId.toString(), widget.dataFromPreviousScreen)
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
              WorkNameWidget(
                  workName: widget.workName, workId: widget.workId.toString()),
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
                      DateTime.parse(_measurementDataToWorkModule
                          .measurement_set_date as String), (newDate) {
                    setState(() {
                      // Update the measurement_set_date with the converted DateTime
                      _measurementDataToWorkModule.measurement_set_date =
                          newDate.toString();
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
                Column(
                  children: [
                    // HtmlWidget(_apiResult),

                    serverMessageWidget(
                      context,
                      _apiResult,
                      _apiResultFlag.toString() != '-1' ? 1 : 0,
                      vsync: this,
                    ),
                    // Text(
                    //   _apiResult,
                    //   style: TextStyle(
                    //       fontSize: 20,
                    //       color: _apiResultFlag.toString() != '-1'
                    //           ? Colors.green
                    //           : Colors.red),
                    // ),
                  ],
                ),
              // Text(_apiResultFlag.toString()),
              ElevatedButton(
                  onPressed: gotToWorkList,
                  child: Row(
                    children: [
                      Text('Got to Work Lists'),
                      Spacer(),
                      Icon(Icons.list)
                    ],
                  ))
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

      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
      try {
        var dataToSend = _measurementDataToWorkModule.toMap();

        dataToSend['office_id'] = (await getOfficeId()).toString();
        dataToSend['role_id'] = (await getUserRoleId()).toString();
        dataToSend['part_or_final'] = 'FINAL';
        // dataToSend['polevar_data'] = jsonEncode(polvar_data);
        dataToSend['polevar_data'] = jsonEncode(polvar_data);

        FormData formData = FormData();

        // print('here2');

        // return;
        var headers = {
          'Authorization': 'Bearer $token',
          'Cookie': 'laravel_session=8XnfA1lbGXvJZWBf8sDwwTWs1YAaekeM0jo0OTXk',
          'Content-Type': 'application/json',
        };

        FormData data = FormData();

        // Iterate through the structured data and add it to the FormData object
        dataToSend.forEach((key, value) {
          if (value.runtimeType != String) {
            value = value.toString();
          }
          print("$key  ->> $value");

          // data.fields.add(MapEntry(key, value.toString()));
        });

        // dataToSend['plg_work_id'] = "28552";
        // dataToSend['wrk_schedule_group_id'] = "16114";
        var dio = Dio();

        setDioAccessokenAndApiKey(dio, await getAccessToken(), config);
        var response = await dio.request(
          '${config.liveServiceUrl}wrk/saveMeasurementWithPolevar',
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
            // final snackBar = SnackBar(
            //   content: Text('Service error . Please try After Some time '),
            //   duration: Duration(
            //       seconds: 10), // How long the snackBar will be displayed
            //   action: SnackBarAction(
            //     label: 'Close',
            //     onPressed: () {
            //       // Code to execute when 'Close' is pressed
            //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
            //     },
            //   ),
            // );

            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          print(json.encode(response.data));

          setState(() {
            _isSubmitting = false;

            _apiResultFlag = response.data['result_flag'];

            String inputString = response.data['result_message'][0];
            List<String> parts = inputString.split('<br/>');
            _apiResult = parts.isNotEmpty ? parts[0] : '';

            // _apiResult = response.data['result_message'][0];
          });

          serverMessageWidget(
            context,
            _apiResult,
            _apiResultFlag.toString() != '-1' ? 1 : 0,
            vsync: this,
          );
        } else {
          print(response.statusMessage);
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

  void gotToWorkList() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => WorkSelection()),
    );
  }
}
