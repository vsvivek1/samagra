import 'package:flutter/material.dart';

class SubmitQueryForm extends StatefulWidget {
  @override
  _SubmitQueryFormState createState() => _SubmitQueryFormState();
}

class _SubmitQueryFormState extends State<SubmitQueryForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String? _selectedSBU;
  String? _selectedCategory;

  final List<String> _sbuOptions = ['Distribution', 'Transmission', 'Generation'];
  final List<String> _categoryOptions = ['Transmission', 'Distribution', 'Generation', 'HR', 'Accounts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit a Query')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _queryController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your Query',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your query' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'SBU',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSBU,
                items: _sbuOptions
                    .map((sbu) => DropdownMenuItem(value: sbu, child: Text(sbu)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSBU = value),
                validator: (value) => value == null ? 'Please select an SBU' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categoryOptions
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                    print('Query: ${_queryController.text}');
                    print('Tags: ${_tagsController.text}');
                    print('SBU: $_selectedSBU');
                    print('Category: $_selectedCategory');
                  }
                },
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


