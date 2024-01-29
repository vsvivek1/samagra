import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class ComingSoonScreen extends StatefulWidget {
  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   height: 200,
            //   width: 200,
            //   child:

            //   FlareActor(
            //     'assets/coming_soon_animation.flr', // Replace with your Flare animation file
            //     animation: 'idle',
            //     fit: BoxFit.contain,
            //   ),
            // ),
            SizedBox(height: 20),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
