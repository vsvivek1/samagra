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
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
