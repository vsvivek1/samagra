import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

getTaskNodes(tasks) {
  return tasks?.map<TreeNode>((task) {
    return TreeNode(content: Text('hi'));
  }).toList();
}

// ignore: non_constant_identifier_names
ListView MeasurementDisplayWidget(measurementDetails) {
  // debugPrint(measurementDetails);
  // debugPrint('measurementDetails above');

  return ListView.builder(
    itemCount: measurementDetails.length,
    itemBuilder: (context, index) {
      final measurement = measurementDetails[index];

      final locationName = measurement['locationName'];
      final tasks = measurement?['tasks'];
      return TreeView(
        nodes: [
          TreeNode(
            content: Flexible(
              child: Text(
                '${index + 1}. $locationName',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            children: tasks == null
                ? [TreeNode(content: Text('No tasks'))]
                : tasks
                    .map<TreeNode>((task) => TreeNode(
                          content: Flexible(
                            child: Text(
                              task['task_name'] ?? 'No task Name',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          children: task['structures'] == null
                              ? [TreeNode(content: Text('No Structures'))]
                              : task['structures']
                                  .map<TreeNode>((str) => TreeNode(
                                        content: Flexible(
                                          child: Text(
                                            str['structure_name'] ??
                                                'No Structure',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        children: [
                                          if (str['materials'] != null)
                                            ...str['materials']
                                                .map<TreeNode>(
                                                    (mat) => TreeNode(
                                                          content: Flexible(
                                                            child: Text(
                                                              mat['material_name'] ??
                                                                  'No Material',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ))
                                                .toList(),
                                          if (str['labour'] != null)
                                            ...str['labour']
                                                .map<TreeNode>(
                                                    (lab) => TreeNode(
                                                          content: Flexible(
                                                            child: Text(
                                                              lab['labour_name'] ??
                                                                  'No Labour',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ))
                                                .toList(),
                                        ],
                                      ))
                                  .toList(),
                        ))
                    .toList(),
          ),
        ],
      );
    },
  );
}
