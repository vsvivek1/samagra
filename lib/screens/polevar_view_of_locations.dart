
import 'package:flutter/material.dart';

class PolvarViewOfLocations extends StatelessWidget {
  final List<Map<dynamic, dynamic>> measurementDetails;

  PolvarViewOfLocations({required this.measurementDetails});
  String _formatText(String text) {
    if (text.length < 8) {
      return text;
    }
    // debugger(when: true);
    List arr = text.split(' ');
    int len = arr.length;
    // debugger(when: true);
    if (len < 5) {
      return text;
    }
    // debugger(when: true);
    String s = '';

    int index = 0;

    //debugger(when: true);
    arr.forEach((element) {
      index++;
      // debugger(when: true);
      if (index % 5 == 0) {
        //debugger(when: true);
        s = s + '\n  ' + element;
      } else {
        // debugger(when: true);
        s = s + ' ' + element;

        // debugger(when: true);
      }
    });

    // print(s);
    return s;

    // Split the text into three lines
    List<String> lines = List.generate((text.length / 10).ceil(),
        (index) => text.substring(index * 10, (index + 1) * 10));
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polvar View Of Locations'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Container(
            // width: 200,
            margin: EdgeInsets.only(top: 25),
            child: DataTable(
              border: TableBorder.all(),
              headingRowHeight: 300,
              columns: _buildColumns(),
              rows: _buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [
      DataColumn(
        label: RotatedBox(quarterTurns: -1, child: Text('Location')),
      ),
    ];

    // Extracting unique materials, labour, and takenbacks
    Set<String> materials = {};
    Set<String> labour = {};
    Set<String> takenbacks = {};

    for (var locationDetails in measurementDetails) {
      for (var task in locationDetails['tasks']) {
        for (var structure in task['structures']) {
          if (structure.containsKey('materials')) {
            for (var material in structure['materials']) {
              materials.add(material['material_name']);
            }
          }
          if (structure.containsKey('labour')) {
            for (var laborItem in structure['labour']) {
              labour.add(laborItem['labour_name']);
            }
          }
          if (structure.containsKey('takenbacks')) {
            for (var takenback in structure['takenbacks']) {
              takenbacks.add(takenback['takenback_name']);
            }
          }
        }
      }
    }

    // Creating DataColumn for each unique material, labour, and takenback
    materials.forEach((material) {
      columns.add(DataColumn(
          label: RotatedBox(
              quarterTurns: -1, child: Text(_formatText(material)))));
    });

    labour.forEach((laborItem) {
      columns.add(DataColumn(
          label: RotatedBox(
              quarterTurns: -1, child: Text(_formatText(laborItem)))));
    });

    takenbacks.forEach((takenback) {
      columns.add(DataColumn(
          label: RotatedBox(
              quarterTurns: -1, child: Text(_formatText(takenback)))));
    });
    //debugger(when: true);

    return columns;
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];

    for (var locationDetails in measurementDetails) {
      String location = locationDetails['locationNo'].toString();
      Map<String, double> quantityMap = {};

      for (var task in locationDetails['tasks']) {
        for (var structure in task['structures']) {
          if (structure.containsKey('materials')) {
            for (var material in structure['materials']) {
              print('Material quantity: ${material['quantity']}');
              quantityMap[material['material_name']] =
                  (quantityMap[material['material_name']] ?? 0.0) +
                      _safeParseDouble(material['quantity']); // Parse as double
            }
          }
          if (structure.containsKey('labour')) {
            for (var laborItem in structure['labour']) {
              print('Labour quantity: ${laborItem['quantity']}');
              quantityMap[laborItem['labour_name']] =
                  (quantityMap[laborItem['labour_name']] ?? 0.0) +
                      _safeParseDouble(
                          laborItem['quantity']); // Parse as double
            }
          }
          if (structure.containsKey('takenbacks')) {
            for (var takenback in structure['takenbacks']) {
              print('Takenback quantity: ${takenback['quantity']}');
              quantityMap[takenback['takenback_name']] =
                  (quantityMap[takenback['takenback_name']] ?? 0.0) +
                      _safeParseDouble(
                          takenback['quantity']); // Parse as double
            }
          }
        }
      }

      List<DataCell> cells = [];
      quantityMap.forEach((itemName, quantity) {
        cells.add(DataCell(Text('$quantity')));
      });

      rows.add(DataRow(
        cells: [
          DataCell(Text(location)),
          ...cells,
        ],
      ));
    }
    //debugger(when: true);
    return rows;
  }

  double _safeParseDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (e) {
      print('Failed to parse double: $value');
      return 0.0;
    }
  }
}
