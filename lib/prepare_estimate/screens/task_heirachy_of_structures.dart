import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';

class TaskHierarchyOfLocation extends StatefulWidget {
  @override
  _TaskHierarchyOfLocationState createState() => _TaskHierarchyOfLocationState();
}

class _TaskHierarchyOfLocationState extends State<TaskHierarchyOfLocation> {
  final storage = FlutterSecureStorage();
  String? selectedStructure;
  String uuid = Uuid().v4();
  bool isSavingLabour = false;
  bool isSavingMaterials = false;
  bool isSavingTakenBacks = false;
  String? savedMessageLabour;
  String? savedMessageMaterials;
  String? savedMessageTakenBacks;
  Map<String, dynamic> estimates = {};

  @override
  void initState() {
    super.initState();
    loadEstimateFromStorage();
  }

  Future<void> loadEstimateFromStorage() async {
    String? storedData = await storage.read(key: 'estimates');
    if (storedData != null) {
      setState(() {
        estimates = json.decode(storedData);
      });
    }
  }

  Future<void> saveEstimateToStorage() async {
    estimates[uuid] = estimates[uuid] ?? {};
    await storage.write(key: 'estimates', value: json.encode(estimates));
  }

  Map<String, dynamic>? getSelectedStructureDetails() {
    if (estimates.containsKey(uuid) && estimates[uuid]['tasks'] != null) {
      for (var task in estimates[uuid]['tasks']) {
        for (var structure in task['structures']) {
          if (structure['structureName'] == selectedStructure) {
            return structure;
          }
        }
      }
    }
    return null;
  }

  void saveLabour() async {
    setState(() {
      isSavingLabour = true;
    });

    await saveEstimateToStorage();
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isSavingLabour = false;
      savedMessageLabour = "Labour details saved!";
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        savedMessageLabour = null;
      });
    });
  }

  void saveMaterials() async {
    setState(() {
      isSavingMaterials = true;
    });

    await saveEstimateToStorage();
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isSavingMaterials = false;
      savedMessageMaterials = "Materials details saved!";
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        savedMessageMaterials = null;
      });
    });
  }

  void saveTakenBacks() async {
    setState(() {
      isSavingTakenBacks = true;
    });

    await saveEstimateToStorage();
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isSavingTakenBacks = false;
      savedMessageTakenBacks = "Taken Backs details saved!";
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        savedMessageTakenBacks = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDetails = getSelectedStructureDetails();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: selectedStructure == null
                      ? Text('Select a structure \nto view details')
                      : DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(text: 'Lab'),
                                  Tab(text: 'MAT'),
                                  Tab(text: 'TknBack'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    buildListView(selectedDetails!['labours'], saveLabour, isSavingLabour, savedMessageLabour),
                                    buildListView(selectedDetails['materials'], saveMaterials, isSavingMaterials, savedMessageMaterials),
                                    buildListView(selectedDetails['takenBacks'], saveTakenBacks, isSavingTakenBacks, savedMessageTakenBacks),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListView(List<dynamic> items, VoidCallback saveFunction, bool isSaving, String? savedMessage) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['type']),
                trailing: SizedBox(
                  width: 50,
                  child: TextFormField(
                    initialValue: item['quantity'].toString(),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item['quantity'] = int.tryParse(value) ?? item['quantity'];
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (savedMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              savedMessage,
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: isSaving ? null : saveFunction,
            child: isSaving
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save'),
          ),
        ),
      ],
    );
  }
} 