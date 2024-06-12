import 'package:flutter/material.dart';

class MeasuredMaterialsView extends StatelessWidget {
  final List<Map<String, dynamic>> measuredMaterials;
  final Map<int, Map<dynamic, dynamic>> estimatedMaterials;

  MeasuredMaterialsView({
    required this.measuredMaterials,
    required this.estimatedMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: DataTable(
          columnSpacing: 30.0,
          columns: [
            DataColumn(label: Text('Material\nName')),
            DataColumn(label: Text('Measured\nQty')),
            DataColumn(label: Text('Est\nQty')),
          ],
          rows: measuredMaterials.map((material) {
            final String materialName = material['material_name'];
            final double measuredQuantity = material['quantity'];
            double estimatedQuantity = 0;

            estimatedMaterials.forEach((key, value) {
              if (value['material']['material_name'] == materialName) {
                estimatedQuantity = value['quantity'] ?? 0;
              }
            });

            return DataRow(
                color: MaterialStateColor.resolveWith((states) =>
                    (estimatedQuantity < measuredQuantity)
                        ? Colors.red
                        : Colors.white),
                cells: [
                  DataCell(Container(
                    width: 100,
                    padding: EdgeInsets.all(5),
                    child: Text(materialName),
                  )),
                  DataCell(Text(measuredQuantity.toString())),
                  DataCell(Text(estimatedQuantity.toString())),
                ]);
          }).toList(),
        ),
      ),
    );
  }
}
