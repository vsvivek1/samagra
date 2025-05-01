import 'package:samagra/screens/add_labour_not_in_estimate.dart';

Future<void> addSelectedLaboursToStructure({
  required List<Map<dynamic, dynamic>> measurementDetails,
  required int selectedLocationIndex,
  required String taskId,
  required String structureId,
  required List<String> selectedLabourIds,
}) async {
  if (selectedLocationIndex < 0 || selectedLocationIndex >= measurementDetails.length) {
    print("Invalid location index");
    return;
  }

  final location = measurementDetails[selectedLocationIndex];
  final tasks = location['tasks'] as List<dynamic>?;

  if (tasks == null || tasks.isEmpty) {
    print("No tasks found in the selected location.");
    return;
  }

  final task = tasks.firstWhere(
    (t) => t['id'].toString() == taskId,
    orElse: () => null,
  );

  if (task == null) {
    print("Task not found");
    return;
  }

  final structures = task['structures'] as List<dynamic>?;

  if (structures == null || structures.isEmpty) {
    print("No structures found in the task.");
    return;
  }

  final structure = structures.firstWhere(
    (s) => s['structureMaster']?['id'].toString() == structureId,
    orElse: () => null,
  );

  if (structure == null) {
    print("Structure not found");
    return;
  }

  // Fetch existing labour list
  final existingLabours = (structure['labour'] as List<dynamic>?) ?? [];

  // Fetch labour master
  final labourMaster = await getLabourGroupMasterDataFromSecureStorage();
  final labourList = labourMaster['labours'] as List<dynamic>? ?? [];

  // Prepare new labour objects
  final newLabours = labourList
      .where((labour) => selectedLabourIds.contains(labour['id'].toString()))
      .where((labour) =>
          !existingLabours.any((existing) => existing['mst_labour_id'].toString() == labour['id'].toString()))
      .map<Map<String, dynamic>>((labour) => {
            'wrk_execution_schedule_id': null,
            'wrk_execution_labour_schedule_id': null,
            'supply_mode': 'CONTRACTOR',
            'mst_labour_id': labour['id'],
            'labour_name': labour['name'],
            'labour_code': labour['code'],
            'mst_uom_id': labour['mst_uom_id'],
            'uom_code': labour['uom'],
            'rate': labour['rate'],
            'quantity': 0,
            'editingMode': false,
          })
      .toList();

  // Add new labours to existing ones
  structure['labour'] = [...existingLabours, ...newLabours];

  print("✅ ${newLabours.length} labours added successfully.");
}
