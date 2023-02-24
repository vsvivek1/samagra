import 'package:flutter/material.dart';
import 'package:samagra/screens/pol_var_screen.dart';

import 'direct_measurement.dart';

class MeasurementOptionScreen extends StatelessWidget {
  const MeasurementOptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an option'),
      ),
      body: Padding(
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
                  MaterialPageRoute(builder: (context) => PolVarScreen()),
                );
              },
              child: Text('measure with a Pol Var'),
            ),
          ],
        ),
      ),
    );
  }
}
