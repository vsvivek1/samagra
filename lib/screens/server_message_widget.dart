import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';

Widget serverMessageWidget(
  BuildContext context,
  String messageFromServer,
  int flag, {
  required TickerProvider vsync, // Require a TickerProvider as a parameter
}) {
  Color backgroundColor = flag == 1 ? Colors.green[100]! : Colors.red[100]!;
  Color borderColor = flag == 1 ? Colors.green : Colors.red;
  Color textColor = flag == 1 ? Colors.green[900]! : Colors.red[900]!;

  return ServerMessage(
    textColor: textColor,
    flag: flag,
    messageFromServer: messageFromServer,
  );

  return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          curve: Curves.easeIn,
          parent: AnimationController(
            vsync: vsync,
            // vsync: Navigator.of(context) as TickerProvider,
            duration: Duration(milliseconds: 500),
          ),
        ),
      ),
      child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceOut,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8.0),
            color: backgroundColor,
          ),
          child: Text('hi')));
}

// ignore: must_be_immutable
class ServerMessage extends StatelessWidget {
  var flag;

  String messageFromServer;

  ServerMessage(
      {super.key,
      required this.textColor,
      required this.flag,
      required this.messageFromServer});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: ksebColor,
          )),
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
    );
  }
}
