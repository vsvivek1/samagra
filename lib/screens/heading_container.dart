import 'package:flutter/material.dart';

class HeadingContainer extends StatelessWidget {
  final String text;
  final Color color;
  final double padding;
  final double fontSize;
  final FontWeight fontWeight;

  const HeadingContainer({
    required Key key,
    required this.text,
    this.color = Colors.blue,
    this.padding = 16.0,
    this.fontSize = 20.0,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      color: color,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}
