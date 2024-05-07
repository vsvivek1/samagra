import 'package:flutter/material.dart';

class MaterialEstimateView extends StatelessWidget {
  final Map EstimatedMaterials;

  MaterialEstimateView({required this.EstimatedMaterials});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          dataRowHeight: 75,
          columns: [
            DataColumn(label: Text('Material\nName')),
            DataColumn(label: Text('Estimated\nQuantity')),
          ],
          rows: EstimatedMaterials.entries
              .map(
                (entry) => DataRow(cells: [
                  DataCell(Container(
                    width: 150,
                    //transformAlignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    child: Text(entry.value['material']['material_name']),
                  )),
                  DataCell(Text(entry.value['quantity'].toString())),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
