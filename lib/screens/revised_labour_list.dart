import 'package:flutter/material.dart';

class RevisedLabourList extends StatelessWidget {
  final List<Map<String, dynamic>> labourQuantities;

  RevisedLabourList({required this.labourQuantities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: labourQuantities.length,
      itemBuilder: (BuildContext context, int index) {
        String labourName = labourQuantities[index]['labour_name'];
        double quantity = labourQuantities[index]['quantity'];

        return ListTile(
          title: Text(labourName),
          subtitle: Text('Quantity: $quantity'),
        );
      },
    );
  }
}
