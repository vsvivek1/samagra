import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

getTaskNodes(measurementDetails) {
  return measurementDetails.map((mdtl) => {
        Card(
          elevation: 10,
// ListTile()
        )
      });
}

// ignore: non_constant_identifier_names
ListView MeasurementDisplayWidget(measurementDetails) {
  print(measurementDetails);
  print('measurementDetails above');

  return ListView.builder(
    itemCount: measurementDetails.length,
    itemBuilder: (context, index) {
      final measurement = measurementDetails[index];

      final locationName = measurement['locationName'];
      final tasks = measurement?['tasks'];

      final taskNodes = tasks?.map<TreeNode>((task) {
        final taskName = task['taskName'];
        final structures = task['Structures'];

        final structureNodes = structures?.map<TreeNode>((structure) {
          final structureName = structure['Structurename'];
          final materials = structure['materials'];
          final labour = structure['labour'];

          final materialNodes = materials?.map<TreeNode>((material) {
            return TreeNode(
              children: [],
              content: Text(material.toString()),
            );
          }).toList();

          final labourNodes = labour?.map<TreeNode>((labourItem) {
            return TreeNode(
              children: [],
              content: Text(labourItem.toString()),
            );
          }).toList();

          return TreeNode(
            children: [
              if (materialNodes != null)
                TreeNode(
                  children: materialNodes,
                  content: Text('Materials'),
                ),
              if (labourNodes != null)
                TreeNode(
                  children: labourNodes,
                  content: Text('Labour'),
                ),
            ],
            content: Text(structureName ?? ''),
          );
        }).toList();

        return TreeNode(
          children: structureNodes,
          content: Text(taskName ?? ''),
        );
      }).toList();

      return TreeView(
        nodes: [
          TreeNode(
            content: Text(locationName ?? ''),
            children: taskNodes ?? [],
          ),
        ],
      );
    },
  );
}
