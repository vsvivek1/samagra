import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/kseb_color.dart';

class ComingSoon extends StatefulWidget {
  const ComingSoon({super.key});

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: SpinKitFadingCube(color: ksebColor)),
          // SpinKitChasingDots(),
          // SpinKitCircle(),
          Text('Work in Progress')
        ],
      ),
      appBar: AppBar(
        title: Text('Coming soon'),
      ),
    );
  }
}
