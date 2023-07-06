import 'package:flutter/material.dart';

class TreeCuttingWalk extends StatefulWidget {
  @override
  _TreeCuttingWalkState createState() => _TreeCuttingWalkState();
}

class _TreeCuttingWalkState extends State<TreeCuttingWalk> {
  List<Plot> plots = [];

  void addPlot(bool isLeft) {
    setState(() {
      plots.add(Plot(isLeft: isLeft));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'myHero',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tree Cutting Walk way'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => addPlot(true),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_left),
                      Text('Add Plot (Left)'),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => addPlot(false),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right),
                      Text('Add Plot (Right)'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: plots.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Plot ${index + 1}'),
                    subtitle: Text(
                        'Lat: ${plots[index].latitude}, Long: ${plots[index].longitude}'),
                    leading: Icon(plots[index].isLeft
                        ? Icons.arrow_left
                        : Icons.arrow_right),
                    onTap: () {
                      // Handle plot tile tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Plot {
  double latitude = 0.0;
  double longitude = 0.0;
  String surveyNumber = '-1';
  String village = 'NIl';
  String taluk = 'Nil';
  String district = 'NIl';
  List<String> trees = [];
  bool isLeft = false;

  Plot({required this.isLeft});

  // Additional properties and methods of the Plot class can be added here
}
