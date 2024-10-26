import 'package:flutter/material.dart';

class AddNewWorkForm extends StatefulWidget {
  @override
  _AddNewWorkFormState createState() => _AddNewWorkFormState();
}

class _AddNewWorkFormState extends State<AddNewWorkForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedScheme;
  String? _selectedSubGroup;
  String? _selectedPriority;
  List<String> _selectedGoals = [];
  bool _isHRBill = false;
  String? _selectedLocalBody;
  String? _selectedAssembly;
  String? _selectedVillage;
  String? _workName;
  String? _workRemarks;
  bool _isConsumer = true;
  String? _beneficiaryName;
  DateTime? _applicationDate;
  String? _consumerNumber;
  String? _applicantNumber;
  String? _estimateReport;
  String? _notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Work')),
      body: Form(
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
                    // Add other schemes here...
                  ],
                  onChanged: (value) => setState(() => _selectedScheme = value),
                ),
                SizedBox(height: 10),

                // Scheme Subgroup Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Scheme Subgroup'),
                  value: _selectedSubGroup,
                  items: [
                    DropdownMenuItem(
                        value: 'Subgroup 1', child: Text('Subgroup 1')),
                    DropdownMenuItem(
                        value: 'Subgroup 2', child: Text('Subgroup 2')),
                    // Add other subgroups here...
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
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedPriority = value),
                ),
                SizedBox(height: 10),

                // Goals Multi-select (Checkboxes)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goals'),
                    CheckboxListTile(
                      title: Text('System Improvement'),
                      value: _selectedGoals.contains('System Improvement'),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected ?? false) {
                            _selectedGoals.add('System Improvement');
                          } else {
                            _selectedGoals.remove('System Improvement');
                          }
                        });
                      },
                    ),
                    // Add more goals as needed...
                  ],
                ),
                SizedBox(height: 10),

                // HR Bill Radio Buttons
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _isHRBill,
                      onChanged: (value) => setState(() => _isHRBill = value!),
                    ),
                    Text('Non-HR Bill'),
                    Radio<bool>(
                      value: true,
                      groupValue: _isHRBill,
                      onChanged: (value) => setState(() => _isHRBill = value!),
                    ),
                    Text('HR Bill'),
                  ],
                ),
                SizedBox(height: 10),

                // Work Name and Remarks
                TextFormField(
                  decoration: InputDecoration(labelText: 'Work Name'),
                  onChanged: (value) => setState(() => _workName = value),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Work Remarks'),
                  onChanged: (value) => setState(() => _workRemarks = value),
                ),
                SizedBox(height: 10),

                // Local Bodies, Assemblies, and Villages (Dropdowns or Multi-select)
                // Add corresponding dropdowns for these fields...

                // Applicant Type (Consumer or Applicant) and Name/Beneficiary
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isConsumer,
                      onChanged: (value) =>
                          setState(() => _isConsumer = value!),
                    ),
                    Text('Consumer'),
                    Radio<bool>(
                      value: false,
                      groupValue: _isConsumer,
                      onChanged: (value) =>
                          setState(() => _isConsumer = value!),
                    ),
                    Text('Applicant'),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Beneficiary Name'),
                  onChanged: (value) =>
                      setState(() => _beneficiaryName = value),
                ),
                // Date Picker for Application Date
                // Consumer/Applicant Number
                // Tabs for Estimate Report, Notes, and Uploads

                // Submit and other actions
                SizedBox(height: 20),
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
