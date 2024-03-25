import 'package:flutter/material.dart';

class MaterialDetailsPopup extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> materialData;

  MaterialDetailsPopup({required this.materialData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Material Details'),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: materialData.entries.map((entry) {
              int materialId = entry.key;
              Map<dynamic, dynamic> materialInfo = entry.value;
              String materialName = materialInfo['material']['material_name'];
              String materialCode = materialInfo['material']['material_code'];
              double quantity = materialInfo['quantity'];

              return Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material ID: $materialId',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Material Name: $materialName'),
                    Text('Material Code: $materialCode'),
                    Text('Quantity: $quantity'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
