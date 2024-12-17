import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:samagra/prepare_estimate/data_fetch_service.dart';
import 'package:samagra/prepare_estimate/locations_and_tasks.dart';
import 'package:samagra/prepare_estimate/models/work_details.dart';
import 'package:samagra/prepare_estimate/screens/add_tasks.dart';
import 'package:samagra/prepare_estimate/screens/review_work_details_page.dart';
// Replace with your actual DataFetchService import

class AddNewWorkForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  AddNewWorkForm({this.initialData});

  @override
  _AddNewWorkFormState createState() => _AddNewWorkFormState();
}

class _AddNewWorkFormState extends State<AddNewWorkForm> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedAssemblies = [
        {'name': 'nodata'}
      ];
      // await _dataFetchService.fetchData('assemblies', 3411);
      final fetchedVillages =
          await _dataFetchService.fetchData('villages', 3411);
      final fetchedLocalBodies =
          await _dataFetchService.fetchData('localBodies', 3411);

      setState(() {
        assemblies = fetchedAssemblies;
        villages = fetchedVillages;
        localBodies = fetchedLocalBodies;

        if (widget.initialData != null) {
          _initializeFromData(widget.initialData!);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: ${e.toString()}")),
      );
    }
  }

  void _initializeFromData(Map<String, dynamic> data) {
    final details = data['details'] ?? {};
    setState(() {
      _selectedScheme = details['scheme'];
      _selectedSubGroup = details['subGroup'];
      _selectedPriority = details['priority'];
      _workName = data['name'];
      _workRemarks = details['remarks'];

      // Preselect items from the fetched data based on passed data
      selectedAssemblies = assemblies
          .where((assembly) =>
              (details['assemblies'] ?? []).contains(assembly['name']))
          .toList();
      selectedVillages = villages
          .where((village) =>
              (details['villages'] ?? []).contains(village['village_name']))
          .toList();
      selectedLocalBodies = localBodies
          .where((localBody) => (details['localBodies'] ?? [])
              .contains(localBody['local_body_name']))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Work')),
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
                      // Scheme Dropdown
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

                      // Scheme Subgroup Dropdown
                      DropdownButtonFormField<String>(
                        decoration:
                            InputDecoration(labelText: 'Scheme Subgroup'),
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

                      // Priority Dropdown
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

                      // Multi-select for Assemblies
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

                      // Multi-select for Villages
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

                      // Multi-select for Local Bodies
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

                      // Work Name and Remarks
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

                      // Save Button
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            WorkDetails workDetails = WorkDetails(
                              scheme: _selectedScheme,
                              subGroup: _selectedSubGroup,
                              priority: _selectedPriority,
                              selectedAssemblies: selectedAssemblies,
                              selectedVillages: selectedVillages,
                              selectedLocalBodies: selectedLocalBodies,
                              workName: _workName,
                              workRemarks: _workRemarks,
                            );

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    
                                    AddTasksWidget(categoryId: '1')
                                    // ReviewDetailsPage(workDetails: workDetails),
                              ),
                            );

                            if (result is WorkDetails) {
                              setState(() {
                                _selectedScheme = result.scheme;
                                _selectedSubGroup = result.subGroup;
                                _selectedPriority = result.priority;
                                selectedAssemblies = result.selectedAssemblies;
                                selectedVillages = result.selectedVillages;
                                selectedLocalBodies =
                                    result.selectedLocalBodies;
                                _workName = result.workName;
                                _workRemarks = result.workRemarks;
                              });
                            }
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
