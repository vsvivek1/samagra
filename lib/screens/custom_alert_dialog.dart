import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  CustomAlertDialog({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: title,
              ),
              SingleChildScrollView(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * .75,
                    width: 400,
                    child: content),
              ),
              ButtonBar(
                children: actions ?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
