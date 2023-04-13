import 'package:flutter/material.dart';
import 'package:samagra/screens/pol_var_screen.dart';

import '../app_theme.dart';
import 'direct_measurement.dart';

class MeasurementOptionScreen extends StatelessWidget {
  final int workId;
  final String workName;

  MeasurementOptionScreen(this.workId, this.workName) {
    print(this.workId);
    print('workid above');
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
        data: ThemeData(buttonColor: AppTheme.dark_grey),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DirectMeasurementScreen()),
                  );
                },
                child: Text('Polarimetric variables'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PolVarScreen(
                            workId: this.workId, workName: this.workName)),
                  );
                },
                child: Text('measure with a Pol Var'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
