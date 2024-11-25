import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/add_new_work_form.dart';
import '../models/work_details_preview.dart';

List<Map<String, dynamic>> fallbackWorksData = [
  {
    "name": "Electrical Maintenance",
    "status": "Pending",
    "details": {
      "scheme": "Deposit Work Capital",
      "subGroup": "Subgroup 1",
      "priority": "High",
      "assemblies": ["Assembly 1", "Assembly 2"],
      "villages": ["Village A", "Village B"],
      "localBodies": ["Local Body 1"],
      "remarks": "Work related to electrical maintenance."
    }
  },
  {
    "name": "Transformer Installation",
    "status": "In Progress",
    "details": {
      "scheme": "Deposit Work Maintenance",
      "subGroup": "Subgroup 2",
      "priority": "Medium",
      "assemblies": ["Assembly 3"],
      "villages": ["Village C"],
      "localBodies": ["Local Body 2", "Local Body 3"],
      "remarks": "Installing a new transformer."
    }
  },
  {
    "name": "Streetlight Repair",
    "status": "Completed",
    "details": {
      "scheme": "Deposit Work Capital",
      "subGroup": "Subgroup 1",
      "priority": "Low",
      "assemblies": ["Assembly 1"],
      "villages": ["Village D", "Village E"],
      "localBodies": ["Local Body 4"],
      "remarks": "Repairing faulty streetlights."
    }
  },
  {
    "name": "Roadside Wiring",
    "status": "Pending",
    "details": {
      "scheme": "Deposit Work Maintenance",
      "subGroup": "Subgroup 2",
      "priority": "High",
      "assemblies": ["Assembly 2", "Assembly 4"],
      "villages": ["Village F"],
      "localBodies": ["Local Body 5"],
      "remarks": "New wiring for roadside lighting."
    }
  },
];

class NewEstimateCreationLandingPage extends StatefulWidget {
  @override
  _NewEstimateCreationLandingPageState createState() =>
      _NewEstimateCreationLandingPageState();
}

class _NewEstimateCreationLandingPageState
    extends State<NewEstimateCreationLandingPage> {
  final List<WorkDetailsPreview> _works = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorks();
  }

  // Simulate fetching works from an API or fallback data
  Future<void> _fetchWorks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API failure
      throw Exception("Simulated API failure");
    } catch (e) {
      final fallbackData = fallbackWorksData.map((work) {
        return WorkDetailsPreview(
          name: work['name'],
          status: work['status'],
          details: work['details'],
        );
      }).toList();

      setState(() {
        _works.addAll(fallbackData);
        _isLoading = false;
      });
    }
  }

  // Add a new work to the list
  void _addNewWork(WorkDetailsPreview work) {
    setState(() {
      _works.add(work);
    });
  }

  // Edit an existing work in the list
  void _editWork(int index, WorkDetailsPreview updatedWork) {
    setState(() {
      _works[index] = updatedWork;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estimate List')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/lineman.webp'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _works.isEmpty
                ? Center(child: Text('No estimates added yet.'))
                : ListView.builder(
                    itemCount: _works.length,
                    itemBuilder: (context, index) {
                      final work = _works[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              '${index + 1}', // Serial number
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(work.name),
                          subtitle: Text('Status: ${work.status}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            // Navigate to AddNewWorkForm with selected work details
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNewWorkForm(
                                  initialData: {
                                    'name': work.name,
                                    'status': work.status,
                                    'details': work.details,
                                  },
                                ),
                              ),
                            );

                            // If updated, modify the list
                            if (result is WorkDetailsPreview) {
                              _editWork(index, result);
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Work',
        onPressed: () async {
          // Navigate to AddNewWorkForm with no data (fetch API data)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewWorkForm()),
          );

          // If a new work is added, update the list
          if (result is WorkDetailsPreview) {
            _addNewWork(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
