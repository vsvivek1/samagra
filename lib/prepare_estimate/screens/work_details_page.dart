// screens/work_details_page.dart
import 'package:flutter/material.dart';
import 'review_work_details_page.dart';
import '../models/work_details_preview.dart';

class WorkDetailsPage extends StatefulWidget {
  @override
  _WorkDetailsPageState createState() => _WorkDetailsPageState();
}

class _WorkDetailsPageState extends State<WorkDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _workName;
  String _status = 'Pending';

  void _saveAndProceed() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final workDetails = {
        'name': _workName,
        'status': _status,
      };

/*       final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewWorkDetailsPage(
            workDetails: workDetails,
          ),
        ),
      );

      if (result is WorkDetailsPreview) {
        Navigator.pop(context, result);
      } */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Work Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Work Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a work name.';
                  }
                  return null;
                },
                onSaved: (value) => _workName = value,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status'),
                value: _status,
                items: ['Pending', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _status = value ?? 'Pending';
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAndProceed,
                child: Text('Save and Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
