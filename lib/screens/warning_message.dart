import 'package:flutter/material.dart';

class WarningMessage extends StatelessWidget {
  final String message;

  const WarningMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 124, 94, 48),
      elevation: 4, // Shadow elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0), // Border radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
