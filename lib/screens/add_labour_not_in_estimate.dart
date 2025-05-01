import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:samagra/screens/add_selected_labours_to_structure.dart';

// ✅ Fixed: Properly decodes and ensures correct return type
Future<Map<String, dynamic>> getLabourGroupMasterDataFromSecureStorage() async {
  final secureStorage = FlutterSecureStorage();
  final data = await secureStorage.read(key: 'getLabourGroupMaster');
  if (data == null) return {};

  try {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else {
      throw FormatException("Expected JSON object, got ${decoded.runtimeType}");
    }
  } catch (e) {
    print("❌ Error decoding JSON: $e");
    return {};
  }
}

// ✅ Main function to show labour selection and update structure
Future<void> addLabourNotInEstimate(
  BuildContext context,
  String taskId,
  String structureId,
  List<Map<dynamic, dynamic>> measurementDetails,
  int selectedLocationIndex,
  VoidCallback onLabourAdded, // 👈 triggers parent setState()
) async {
  Map<String, dynamic> labourData = await getLabourGroupMasterDataFromSecureStorage();
  List<dynamic> labourList = labourData['labours'] ?? [];

  TextEditingController searchController = TextEditingController();
  Set<String> selectedLabourIds = {};

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        String query = searchController.text.toLowerCase();

        List<dynamic> filteredLabours = labourList.where((labour) {
          return (labour['name'] ?? '').toLowerCase().contains(query);
        }).toList();

        List<String> selectedNames = labourList
            .where((labour) => selectedLabourIds.contains(labour['id'].toString()))
            .map((labour) => labour['name'].toString())
            .toList();

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Labours'),
              SizedBox(height: 4),
              Text(
                '${selectedLabourIds.length} selected',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              if (selectedNames.isNotEmpty) ...[
                SizedBox(height: 6),
                Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            '${index + 1}. $name',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Labour',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredLabours.length,
                    itemBuilder: (context, index) {
                      final labour = filteredLabours[index];
                      final labourId = labour['id'].toString();
                      final isSelected = selectedLabourIds.contains(labourId);

                      return CheckboxListTile(
                        title: Text(labour['name'] ?? 'Unknown Labour'),
                        value: isSelected,
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              selectedLabourIds.add(labourId);
                            } else {
                              selectedLabourIds.remove(labourId);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedLabourIds.toList());
              },
              child: Text('Confirm'),
            ),
          ],
        );
      });
    },
  ).then((selectedIds) async {
    if (selectedIds != null && selectedIds.isNotEmpty) {
      await addSelectedLaboursToStructure(
        measurementDetails: measurementDetails,
        selectedLocationIndex: selectedLocationIndex,
        taskId: taskId,
        structureId: structureId,
        selectedLabourIds: selectedIds,
      );

      print('✅ Selected Labour IDs: $selectedIds');
      onLabourAdded(); // ⬅️ notify parent to rebuild
    }
  });
}
