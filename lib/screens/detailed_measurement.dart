import 'package:flutter/material.dart';

class DetailedMeasurement extends StatefulWidget {
  final List<String> taskList;

  DetailedMeasurement({required Key key, required this.taskList})
      : super(key: key);

  @override
  _DetailedMeasurementState createState() => _DetailedMeasurementState();
}

class _DetailedMeasurementState extends State<DetailedMeasurement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Measurement'),
      ),
      body: ListView.builder(
        itemCount: widget.taskList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(widget.taskList[index]),
          );
        },
      ),
    );
  }
}
