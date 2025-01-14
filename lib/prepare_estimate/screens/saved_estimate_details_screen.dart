import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/prepare_estimate/screens/add_tasks.dart';

class SavedEstimateDetailsScreen extends StatefulWidget {
  final String uuid;

  SavedEstimateDetailsScreen({required this.uuid});

  @override
  _SavedEstimateDetailsScreenState createState() =>
      _SavedEstimateDetailsScreenState();
}

class _SavedEstimateDetailsScreenState
    extends State<SavedEstimateDetailsScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  Map<String, dynamic>? estimateDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEstimateDetails();
  }

  Future<void> _fetchEstimateDetails() async {
    try {
      setState(() {
        isLoading = true;
      });

      final storedData = await _secureStorage.read(key: 'estimates');
      if (storedData != null) {
        final Map<String, dynamic> storedMap = jsonDecode(storedData);
        setState(() {
          estimateDetails = storedMap[widget.uuid];
        });
      } else {
        _showError("No data found for this estimate.");
      }
    } catch (e) {
      _showError("Error fetching data: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Saved Estimate Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (estimateDetails == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Saved Estimate Details')),
        body: Center(child: Text('No details available for this estimate.')),
      );
    }

    final List<dynamic> sections = [
      {'title': 'Villages', 'data': estimateDetails?['villages'], 'keys': ['No.', 'Village Name'], 'field': 'village_name'},
      {'title': 'Assemblies', 'data': estimateDetails?['assemblies'], 'keys': ['No.', 'Assembly Name'], 'field': 'name'},
      {'title': 'Local Bodies', 'data': estimateDetails?['localBodies'], 'keys': ['No.', 'Local Body Name'], 'field': 'local_body_name'},
      {'title': 'Tasks', 'data': estimateDetails?['tasks'], 'keys': ['No.', 'Task Name', 'Quantity'], 'fields': ['name', 'quantity']},
      {'title': 'Structures', 'data': estimateDetails?['structures'], 'keys': ['No.', 'Structure Name'], 'field': 'name'},
      {'title': 'Materials', 'data': estimateDetails?['materials'], 'keys': ['No.', 'Material Name', 'Quantity'], 'fields': ['name', 'quantity']},
      {'title': 'Labours', 'data': estimateDetails?['labours'], 'keys': ['No.', 'Labour Name', 'Quantity'], 'fields': ['name', 'quantity']},
      {'title': 'Taken Back', 'data': estimateDetails?['takenBack'], 'keys': ['No.', 'Item Name', 'Quantity'], 'fields': ['name', 'quantity']},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Estimate Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Work Name: ${estimateDetails?['name'] ?? 'Unnamed Work'}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Scheme: ${estimateDetails?['scheme'] ?? 'N/A'}"),
              Text("Subgroup: ${estimateDetails?['subGroup'] ?? 'N/A'}"),
              Text("Priority: ${estimateDetails?['priority'] ?? 'N/A'}"),
              SizedBox(height: 12),
              Text(
                "Remarks: ${estimateDetails?['remarks'] ?? 'No remarks available.'}",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              ...sections.map((section) => _buildTableSection(
                    context,
                    section['title'],
                    section['data'] ?? [],
                    section['keys'],
                    section['field'] ?? section['fields'],
                  )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTasksWidget(uuId: widget.uuid),
                        ),
                      );
                    },
                    child: Text('Proceed to Add Tasks'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection(
      BuildContext context, String title, List<dynamic> data, List<String> headers, dynamic fieldKeys) {
    if (data.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("No $title available.", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: headers.asMap().map((i, _) => MapEntry(i, FlexColumnWidth(1))),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: headers.map((header) => _buildTableCell(header, isHeader: true)).toList(),
            ),
            ...data.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              return TableRow(
                children: [
                  _buildTableCell(index.toString()),
                  ..._buildRowCells(item, fieldKeys),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

 List<Widget> _buildRowCells(dynamic item, dynamic fieldKeys) {
  // If the item is a String, just display it
  if (item is String) {
    return [_buildTableCell(item)];
  }

  // If the item is a Map, access fields using keys
  if (item is Map<String, dynamic>) {
    if (fieldKeys is String) {
      // Single field access
      return [_buildTableCell(item[fieldKeys]?.toString() ?? 'N/A')];
    } else if (fieldKeys is List) {
      // Multiple fields access
      return fieldKeys.map((key) {
        return _buildTableCell(item[key]?.toString() ?? 'N/A');
      }).toList();
    }
  }

  // If the item is a List, join items into a string
  if (item is List) {
    return [_buildTableCell(item.join(', '))];
  }

  // Default fallback
  return [_buildTableCell('N/A')];
}


  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
        textAlign: TextAlign.center,
      ),
    );
  }
}
