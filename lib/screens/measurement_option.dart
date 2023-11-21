import 'package:flutter/material.dart';
import 'package:samagra/screens/pol_var_screen.dart';
import 'package:samagra/screens/work_name_widget.dart';

import '../app_theme.dart';
import 'direct_measurement.dart';

class MeasurementOptionScreen extends StatelessWidget {
  final int workId;
  final String workName;
  final String workCode;
  final String measurementSetId;
  final String workScheduleGroupId;

  bool isMuted;

  // var workCode;

  MeasurementOptionScreen(this.workId, this.workName, this.workCode,
      this.measurementSetId, this.workScheduleGroupId, this.isMuted) {
    // print(this.workId);
    // print('workid above');
  }
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.grey.withOpacity(0.7),
        title: Text('Select an option'),
      ),
      body: Theme(
        data: ThemeData(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WorkNameWidget(workName: this.workName),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromARGB(255, 148, 148, 148))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DirectMeasurementScreen()),
                  );
                },
                child: Text('Direct measurement'),
              ),
              SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => DirectMeasurementScreen()),
              //     );
              //   },
              //   child: Text('Polarimetric variables'),
              // ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromARGB(255, 148, 148, 148))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PolVarScreen(
                            workId: this.workId,
                            workName: this.workName,
                            workCode: this.workCode,
                            measurementSetId: this.measurementSetId,
                            workScheduleGroupId: this.workScheduleGroupId,
                            isMuted: this.isMuted)),
                  );
                },
                child: Text('Measure with a Pol Var'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
