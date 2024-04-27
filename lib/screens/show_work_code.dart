import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';

class ShowWorkCode extends StatelessWidget {
  final String workCode;

  const ShowWorkCode({
    super.key,
    required this.workCode,
  });

  // var workCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: SweepGradient(colors: [ksebColor, Colors.white]),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ]),
      padding: const EdgeInsets.all(15.0),
      child: Text(
        'WorkCode: $workCode',
        style: TextStyle(
            textBaseline: TextBaseline.ideographic,
            fontSize: 14,
            wordSpacing: 5,
            color: ksebColor),
      ),
    );
  }
}
