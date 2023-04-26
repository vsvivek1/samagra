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
TreeView MeasurementDisplayWidget(measurementDetails) {
  return TreeView(
    nodes: [
      TreeNode(content: Text(measurementDetails[0]['locationName']), children: [
        TreeNode(
            children: [
              TreeNode(
                  children: [
                    TreeNode(
                        children: [],
                        content: Text(measurementDetails[0]['measurement']
                                ['tasks'][0]['Structures'][0]['materials'][0]
                            .toString())),
                    TreeNode(
                        children: [],
                        content: Text(measurementDetails[0]['measurement']
                                ['tasks'][0]['Structures'][0]['labour'][0]
                            .toString()))
                  ],
                  content: Text(measurementDetails[0]['measurement']['tasks'][0]
                      ['Structures'][0]['Structurename']))
            ],
            content: Text(
                measurementDetails[0]['measurement']['tasks'][0]['taskName'])),
      ])
    ],
  );
}
