import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';

Widget serverMessageWidget(
    BuildContext context, String messageFromServer, int flag) {
  Color backgroundColor = flag == 1 ? Colors.green[100]! : Colors.red[100]!;
  Color borderColor = flag == 1 ? Colors.green : Colors.red;
  Color textColor = flag == 1 ? Colors.green[900]! : Colors.red[900]!;

  return FadeTransition(
    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: AnimationController(
          vsync: Navigator.of(context) as TickerProvider,
          duration: Duration(milliseconds: 500),
        ),
      ),
    ),
    child: AnimatedContainer(
      duration: Duration(milliseconds: 2000),
      curve: Curves.bounceOut,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Samagra Says ...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              fontSize: 18.0,
              color: ksebColor, // Replace ksebColor with your desired color
            ),
          ),
          SizedBox(height: 10),
          Text(
            flag == 1 ? 'Success:' : 'Failure:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: textColor,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            messageFromServer,
            style: TextStyle(fontSize: 14.0, color: textColor),
          ),
        ],
      ),
    ),
  );
}
