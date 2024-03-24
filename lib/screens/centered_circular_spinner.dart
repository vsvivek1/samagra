import 'package:flutter/material.dart';

class CenteredCircularSpinner extends StatelessWidget {
  const CenteredCircularSpinner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
