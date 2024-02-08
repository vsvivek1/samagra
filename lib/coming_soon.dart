import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          SpinKitChasingDots(),
          SpinKitCircle(),
          Text('Work in Progress')
        ],
      ),
      appBar: AppBar(
        title: Text('Coming soon'),
      ),
    );
  }
}
