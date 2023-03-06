import 'package:flutter/material.dart';

import '../app_theme.dart';

class PolVarScreen extends StatefulWidget {
  @override
  _PolVarScreenState createState() => _PolVarScreenState();
}

class _PolVarScreenState extends State<PolVarScreen> {
  int _numberOfLocations = 1;
  List<String> _templates = [
    'Template 1',
    'Template 2',
    'Template 3',
    'Template 4',
    'Template 5',
    'Template 6',
    'Template 7',
    'Template 8',
    'Template 9',
    'Template 10',
  ];
  List<String> _selectedTemplates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.grey.withOpacity(0.7),
        title: Text('Select Locations and Templates'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Number of Locations',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _numberOfLocations = int.tryParse(value) ?? 1;
                });
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'From Location',
                    border: OutlineInputBorder(),
                  ),
                  child: TextField(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'To Location',
                    border: OutlineInputBorder(),
                  ),
                  child: TextField(),
                ),
              ),
              IconButton(
                onPressed: saveFromAndTwoLocation,
                icon: Icon(Icons.save),
                color: Colors.grey,
              )
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    itemCount: _templates.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTemplates.add(_templates[index]);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(_templates[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _numberOfLocations,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.all(8.0),
                        height: 50.0,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            _selectedTemplates.length > index
                                ? _selectedTemplates[index]
                                : 'Select a template',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveFromAndTwoLocation() {
    print('pressed');
  }
}
