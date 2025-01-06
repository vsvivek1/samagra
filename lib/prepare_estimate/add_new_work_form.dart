import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:samagra/prepare_estimate/screens/saved_estimate_details_screen.dart';
import 'package:samagra/prepare_estimate/data_fetch_service.dart';

class AddNewWorkForm extends StatefulWidget {
  final String uuid;

  AddNewWorkForm({required this.uuid});

  @override
  _AddNewWorkFormState createState() => _AddNewWorkFormState();
}

class _AddNewWorkFormState extends State<AddNewWorkForm> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final DataFetchService _dataFetchService = DataFetchService();

  String? _selectedScheme;
  String? _selectedSubGroup;
  String? _selectedPriority;
  List<Map<String, dynamic>> assemblies = [];
  List<Map<String, dynamic>> villages = [];
  List<Map<String, dynamic>> localBodies = [];
  List<Map<String, dynamic>> selectedAssemblies = [];
  List<Map<String, dynamic>> selectedVillages = [];
  List<Map<String, dynamic>> selectedLocalBodies = [];
  String? _workName;
  String? _workRemarks;
  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    setState(() {
      isLoading = true;
    });

    try {

          final fetchedAssemblies = [{'name': 'Assembly 1'}, {'name': 'Assembly 2'}];
      final fetchedVillages = await _dataFetchService.fetchData('villages', 3411);
      final fetchedLocalBodies =
          await _dataFetchService.fetchData('localBodies', 3411);

      setState(() {
        assemblies = fetchedAssemblies;
        villages = fetchedVillages;
        localBodies = fetchedLocalBodies;
      });
      // Fetch existing data if available
      final storedData = await _secureStorage.read(key: 'estimates');
      if (storedData != null) {
        final Map<String, dynamic> storedMap = jsonDecode(storedData);
        if (storedMap.containsKey(widget.uuid)) {
          isEditing = true;
          _initializeFromData(storedMap[widget.uuid]);
        }
      }

      // Fetch assemblies, villages, and local bodies
  
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeFromData(Map<String, dynamic> data) {
    final details = data ?? {};
    setState(() {
      _selectedScheme = details['scheme'];
      _selectedSubGroup = details['subGroup'];
      _selectedPriority = details['priority'];
      _workName = data['name'];
      _workRemarks = details['remarks'];


     


      selectedAssemblies = assemblies
          .where((assembly) =>
              (details['assemblies'] ?? []).contains(assembly['name']))
              
              
              .toList(); //.contains(assembly['name']))
        
      selectedAssemblies;;

        
      selectedVillages = villages
          .where((village) =>
              (details['villages'] ?? []).contains(village['village_name']))
              .toList();


      selectedLocalBodies = localBodies
          .where((localBody) => (details['localBodies'] ?? []).
          contains(localBody['local_body_name'])).toList();



print('hi');

    });
  }

  Future<void> _saveToSecureStorage(String uuid, Map<String, dynamic> workDetails) async {
    try {
      final storedData = await _secureStorage.read(key: 'estimates');
      final Map<String, dynamic> storedMap =
          storedData != null ? jsonDecode(storedData) : {};
      storedMap[uuid] = workDetails;
      await _secureStorage.write(key: 'estimates', value: jsonEncode(storedMap));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Work' : 'Add New Work'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Scheme'),
                        value: _selectedScheme,
                        items: [
                          DropdownMenuItem(
                              value: 'Deposit Work Capital',
                              child: Text('Deposit Work Capital')),
                          DropdownMenuItem(
                              value: 'Deposit Work Maintenance',
                              child: Text('Deposit Work Maintenance')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedScheme = value),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Scheme Subgroup'),
                        value: _selectedSubGroup,
                        items: [
                          DropdownMenuItem(
                              value: 'Subgroup 1', child: Text('Subgroup 1')),
                          DropdownMenuItem(
                              value: 'Subgroup 2', child: Text('Subgroup 2')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedSubGroup = value),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Priority'),
                        value: _selectedPriority,
                        items: [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(
                              value: 'Medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedPriority = value),
                      ),
                      SizedBox(height: 10),
                      Text("Select Assemblies:"),
                      MultiSelectDialogField(
                        items: assemblies
                            .map((item) => MultiSelectItem(item, item['name']))
                            .toList(),
                        title: Text("Assemblies"),
                        buttonText: Text("Select Assemblies"),
                        initialValue: selectedAssemblies,
                        onConfirm: (values) {
                          setState(() {
                            selectedAssemblies =
                                List<Map<String, dynamic>>.from(values);
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      Text("Select Villages:"),
                      MultiSelectDialogField(
                        items: villages
                            .map((item) =>
                                MultiSelectItem(item, item['village_name']))
                            .toList(),
                        title: Text("Villages"),
                        buttonText: Text("Select Villages"),
                        initialValue: selectedVillages,
                        onConfirm: (values) {
                          setState(() {
                            selectedVillages =
                                List<Map<String, dynamic>>.from(values);
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      Text("Select Local Bodies:"),
                      MultiSelectDialogField(
                        items: localBodies
                            .map((item) =>
                                MultiSelectItem(item, item['local_body_name']))
                            .toList(),
                        title: Text("Local Bodies"),
                        buttonText: Text("Select Local Bodies"),
                        initialValue: selectedLocalBodies,
                        onConfirm: (values) {
                          setState(() {
                            selectedLocalBodies =
                                List<Map<String, dynamic>>.from(values);
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Work Name'),
                        initialValue: _workName,
                        onChanged: (value) => setState(() => _workName = value),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Work Remarks'),
                        initialValue: _workRemarks,
                        onChanged: (value) =>
                            setState(() => _workRemarks = value),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            Map<String, dynamic> workDetails = {
                              'scheme': _selectedScheme,
                              'subGroup': _selectedSubGroup,
                              'priority': _selectedPriority,
                              'assemblies': selectedAssemblies
                                  .map((e) => e['name'])
                                  .toList(),
                              'villages': selectedVillages
                                  .map((e) => e['village_name'])
                                  .toList(),
                              'localBodies': selectedLocalBodies
                                  .map((e) => e['local_body_name'])
                                  .toList(),
                              'name': _workName,
                              'remarks': _workRemarks,
                              'status': 'inProgress',
                            };

                            await _saveToSecureStorage(widget.uuid, workDetails);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavedEstimateDetailsScreen(
                                  uuid: widget.uuid,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Save & View Details'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
