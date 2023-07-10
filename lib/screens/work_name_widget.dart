import 'package:flutter/material.dart';

class WorkNameWidget extends StatelessWidget {
  final String workName;
  final Color color;
  final String label;

  const WorkNameWidget(
      {Key? key,
      required this.workName,
      this.color = const Color(0xFF800000),
      this.label = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, top: 20),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.9),
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label + workName,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Verdana',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: color),
      ),
    );
  }
}
