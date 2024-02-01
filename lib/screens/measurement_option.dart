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
    return new WillPopScope(
      onWillPop: () async {
        print('pop');
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.grey.withOpacity(0.7),
          title: Text('Select an option'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: AbsorbPointer(
            absorbing: false,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () {
                Navigator.pushNamed(context, '/home');
              },
              onDoubleTap: () {
                print('hid');
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
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
                }

                if (details.primaryVelocity! > 0) {
                  // printWidgetTree(context);

                  // Navigator.pushNamed(context, '/home');
                  Navigator.pop(context);

                  // print('hi');
                  // print(details);
                  // Navigator.pushReplacementNamed(context, '/home');
                  // Swiped from left to right (right to left motion)
                  // print('Swipe back detected!');
                  // Your custom handling for swipe back
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkNameWidget(
                    workName: this.workName,
                    workId: this.workId.toString(),
                  ),
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
        ),
      ),
    );
  }
}
