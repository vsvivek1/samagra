import 'package:flutter/material.dart';

class UATTestWidget extends StatelessWidget {
  final bool isUATTest;

  const UATTestWidget({Key? key, required this.isUATTest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isUATTest
        ? Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'UAT TEST',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : SizedBox(); // Empty SizedBox if not in UAT Test mode
  }
}
