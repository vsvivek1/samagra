import 'package:flutter/material.dart';

class DirectMeasurementScreen extends StatelessWidget {
  const DirectMeasurementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct measurement'),
      ),
      body: Center(
        child: Text('Direct measurement screen'),
      ),
    );
  }
}
