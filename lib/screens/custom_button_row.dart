import 'package:flutter/material.dart';

class CustomButtonRow extends StatelessWidget {
  final int locationNumber;
  final int workId;

  CustomButtonRow({required this.locationNumber, required this.workId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.work),
          color: Colors.red,
          onPressed: () {
            showAbstractOfLabor(locationNumber, workId);
          },
        ),
        Text('Labor'),
        IconButton(
          icon: Icon(Icons.shopping_basket),
          color: Colors.yellow,
          onPressed: () {
            showAbstractOfMaterial(locationNumber, workId);
          },
        ),
        Text('Material'),
        IconButton(
          icon: Icon(Icons.rotate_left),
          color: Colors.blue,
          onPressed: () {
            showAbstractOfTakenBacks(locationNumber, workId);
          },
        ),
        Text('Taken Backs'),
      ],
    );
  }

  void showAbstractOfLabor(int locationNumber, int workId) {
    // Add your logic here to show the abstract of labor
    print(
        'Showing abstract of labor for Location $locationNumber and Work ID $workId');
  }

  void showAbstractOfMaterial(int locationNumber, int workId) {
    // Add your logic here to show the abstract of material
    print(
        'Showing abstract of material for Location $locationNumber and Work ID $workId');
  }

  void showAbstractOfTakenBacks(int locationNumber, int workId) {
    // Add your logic here to show the abstract of taken backs
    print(
        'Showing abstract of taken backs for Location $locationNumber and Work ID $workId');
  }
}
