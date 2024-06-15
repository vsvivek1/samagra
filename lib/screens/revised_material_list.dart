import 'package:flutter/material.dart';

class RevisedMaterialList extends StatelessWidget {
  final List materialQuantities;

  RevisedMaterialList({required this.materialQuantities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: materialQuantities.length,
      itemBuilder: (BuildContext context, int index) {
        String materialName = materialQuantities[index]['material_name'];
        double quantity = materialQuantities[index]['quantity'];

        return ListTile(
          title: Text(materialName),
          subtitle: Text('Quantity: $quantity'),
        );
      },
    );
  }
}
