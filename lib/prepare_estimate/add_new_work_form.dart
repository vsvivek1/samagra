import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'data_fetch_service.dart'; // Import your DataFetchService

class AddNewWorkForm extends StatefulWidget {
  @override
  _AddNewWorkFormState createState() => _AddNewWorkFormState();
}

class _AddNewWorkFormState extends State<AddNewWorkForm> {
  final _formKey = GlobalKey<FormState>();
  final DataFetchService _dataFetchService = DataFetchService();

  String? _selectedScheme;
  String? _selectedSubGroup;
  String? _selectedPriority;
  List<String> _selectedGoals = [];
  bool _isHRBill = false;
  String? _workName;
  String? _workRemarks;

  // Multi-select related fields
  List<Map<String, dynamic>> assemblies = [];
  List<Map<String, dynamic>> villages = [];
  List<Map<String, dynamic>> localBodies = [];
  List<Map<String, dynamic>> selectedAssemblies = [];
  List<Map<String, dynamic>> selectedVillages = [];
  List<Map<String, dynamic>> selectedLocalBodies = [];
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
      final fetchedAssemblies = await _dataFetchService.fetchData(
          'assemblies', 3411); // Example officeId
      final fetchedVillages = await _dataFetchService.fetchData(
          'villages', 3411); // Example districtId
      final fetchedLocalBodies = await _dataFetchService.fetchData(
          'localBodies', 3411); // Example officeId

      setState(() {
        assemblies = fetchedAssemblies;
        villages = fetchedVillages;
        localBodies = fetchedLocalBodies;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Work')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      Text(
                        "Select Assemblies:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      MultiSelectDialogField(
                        items: assemblies
                            .map((item) => MultiSelectItem(item, item['name']))
                            .toList(),
                        title: Text("Assemblies"),
                        buttonText: Text("Select Assemblies"),
                        onConfirm: (values) {
                          setState(() {
                            selectedAssemblies =
                                List<Map<String, dynamic>>.from(values);
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      // Multi-select for Villages
                      Text(
                        "Select Villages:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      MultiSelectDialogField(
                        items: villages
                            .map((item) => MultiSelectItem(item, item['name']))
                            .toList(),
                        title: Text("Villages"),
                        buttonText: Text("Select Villages"),
                        onConfirm: (values) {
                          setState(() {
                            selectedVillages =
                                List<Map<String, dynamic>>.from(values);
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      // Multi-select for Local Bodies
                      Text(
                        "Select Local Bodies:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      MultiSelectDialogField(
                        items: localBodies
                            .map((item) => MultiSelectItem(item, item['name']))
                            .toList(),
                        title: Text("Local Bodies"),
                        buttonText: Text("Select Local Bodies"),
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
                        onChanged: (value) => setState(() => _workName = value),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Work Remarks'),
                        onChanged: (value) =>
                            setState(() => _workRemarks = value),
                      ),
                      SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Perform form submission
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
