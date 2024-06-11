import 'package:flutter/material.dart';
import 'package:samagra/main.dart';
import 'package:samagra/screens/Untitled-1.dart';

class ServerError extends StatefulWidget {
  String msg;
  ServerError(this.msg, {super.key});

  @override
  State<ServerError> createState() => _ServerErrorState();
}

class _ServerErrorState extends State<ServerError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 250),
          child: Column(
            children: [
              Text(widget.msg.toString()),
              ElevatedButton(
                  onPressed: (() {
                    relogin();
                  }),
                  child: Text('relogin'))
            ],
          ),
        ),
      ),
    );
  }

  void relogin() {
    Navigator.push(context, MaterialPageRoute(builder: ((context) {
      return Samagra();
    })));
  }
}
