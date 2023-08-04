import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/secure_storage/common_functions.dart';
import 'package:samagra/secure_storage/secure_storage.dart';

class MeasurementDetails {
  bool isPremeasurement;
  bool isPart;
  DateTime measurementSetDate;
  DateTime commencementDate;
  DateTime completionDate;

  MeasurementDetails({
    required this.isPremeasurement,
    required this.isPart,
    DateTime? measurementSetDate,
    DateTime? commencementDate,
    DateTime? completionDate,
    String seat_id: '',
  })  : this.measurementSetDate = measurementSetDate ?? DateTime.now(),
        this.commencementDate = commencementDate ?? DateTime.now(),
        this.completionDate = completionDate ?? DateTime.now();
}

class SaveToWorkModule extends StatefulWidget {
  final Object dataFromPreviousScreen;

  SaveToWorkModule({required this.dataFromPreviousScreen});

  @override
  _SaveToWorkModuleState createState() => _SaveToWorkModuleState();
}

class _SaveToWorkModuleState extends State<SaveToWorkModule> {
  final _formKey = GlobalKey<FormState>();
  late MeasurementDetails _measurementDetails;

  late Map polVarMeasurementObject;

  bool _isSubmitting = false;
  String _apiResult = '';

  @override
  void initState() {
    super.initState();

    polVarMeasurementObject = widget.dataFromPreviousScreen as Map;
    //  widget.dataFromPreviousScreen as MeasurementDetails ??
    _measurementDetails = MeasurementDetails(
      isPremeasurement: false,
      isPart: true,
      measurementSetDate: DateTime.now(),
      commencementDate: DateTime.now(),
      completionDate: DateTime.now(),
    );
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
                value: _measurementDetails.isPremeasurement,
                onChanged: (newValue) {
                  setState(() {
                    _measurementDetails.isPremeasurement = newValue!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Is This a  Part Measurement ? '),
                value: _measurementDetails.isPart,
                onChanged: (newValue) {
                  setState(() {
                    _measurementDetails.isPart = newValue!;
                  });
                },
              ),
              ListTile(
                title: Text('Date of Commencement of Work'),
                subtitle: Text(_measurementDetails.commencementDate.toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(
                      context, _measurementDetails.commencementDate, (newDate) {
                    setState(() {
                      _measurementDetails.commencementDate = newDate;
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text('Date of Completion of Work'),
                subtitle: Text(_measurementDetails.completionDate.toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(
                      context, _measurementDetails.completionDate, (newDate) {
                    setState(() {
                      _measurementDetails.completionDate = newDate;
                    });
                  }),
                ),
              ),
              ListTile(
                title: Text('Measurement Set Date'),
                subtitle:
                    Text(_measurementDetails.measurementSetDate.toString()),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(
                      context, _measurementDetails.measurementSetDate,
                      (newDate) {
                    setState(() {
                      _measurementDetails.measurementSetDate = newDate;
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final storage = SecureStorage();

      final loginDetails1 =
          await storage.getSecureAllStorageDataByKey('loginDetails');
      final loginDetails = loginDetails1['loginDetails'];

      final currentSeatDetails = getCurrentSeatDetails(loginDetails);

      // final officeCode = currentSeatDetails['office']['office_code'];
      final officeId = currentSeatDetails['office_id'];

      print("currentSeatDetails + $currentSeatDetails ");

      debugger;

      setState(() {
        _isSubmitting = true;
        _apiResult =
            ''; // Clear the result message on every submission attempt.
      });
      _formKey.currentState!.save();

      // Perform the POST request using Dio
      Dio dio = Dio();
      try {
        // Convert the MeasurementDetails object to a map
        Map<String, dynamic> dataToSend = {
          'isPremeasurement': _measurementDetails.isPremeasurement,
          'isPart': _measurementDetails.isPart,
          'measurementSetDate':
              _measurementDetails.measurementSetDate.toIso8601String(),
          'commencementDate':
              _measurementDetails.commencementDate.toIso8601String(),
          'completionDate':
              _measurementDetails.completionDate.toIso8601String(),
        };

        // Send the POST request to the specified URL
        var response = await dio.post(
          'http://erpuat.kseb.in/api/wrk/saveMeasurementWithPolevar',
          data: dataToSend,
        );

        // Handle the response
        if (response.statusCode == 200) {
          setState(() {
            _isSubmitting = false;
            _apiResult = 'Success';
          });
          // Do something with the successful response, if needed.
        } else {
          setState(() {
            _isSubmitting = false;
            _apiResult = 'Failed';
          });
          // Handle the failure case, if needed.
        }
      } catch (e) {
        // Handle any errors that occurred during the request
        setState(() {
          _isSubmitting = false;
          _apiResult = 'Error: $e';
        });
      }
    }
  }
}
