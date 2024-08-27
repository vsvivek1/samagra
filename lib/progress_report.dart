import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressReportScreen extends StatefulWidget {
  @override
  _ProgressReportScreenState createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  List<ProgressReportEntry> _entries = [];
  List<JourneyLeg> _journeyLegs = []; // Manage journey legs here
  String designation = "Assistant Engineer";
  String officeName = "KSEB";

  @override
  void initState() {
    super.initState();
    _generateDefaultEntries();
  }

  void _generateDefaultEntries() {
    DateTime now = DateTime.now();
    int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(now.year, now.month, day);
      bool isHoliday =
          _isSecondSaturday(date) || date.weekday == DateTime.sunday;
      String description =
          isHoliday ? "Holiday" : "Duty as $designation at $officeName";
      _entries.add(ProgressReportEntry(
        date: date,
        description: description,
      ));
    }
  }

  bool _isSecondSaturday(DateTime date) {
    return date.weekday == DateTime.saturday && (date.day / 7).ceil() == 2;
  }

  void _editDescription(int index, String newDescription) {
    setState(() {
      _entries[index].description = newDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Progress Report"),
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          ProgressReportEntry report = _entries[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(report.date),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(report.description),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showEditDialog(context, index);
                    },
                    child: Text('Add/Edit Activity'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    TextEditingController _descriptionController =
        TextEditingController(text: _entries[index].description);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool _includeReverse = false;

            return AlertDialog(
              title: Text("Edit Description"),
              content: SizedBox(
                width: double.maxFinite,
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: "Journey"),
                          Tab(text: "Leave"),
                          Tab(text: "Field Visit"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildJourneyTab(setState),
                            _buildLeaveTab(_descriptionController, setState),
                            _buildFieldVisitTab(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Additional details",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    _editDescription(index, _descriptionController.text);
                    Navigator.of(context).pop();
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _descriptionController.dispose();
    });
  }

  Widget _buildJourneyTab(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final JourneyLeg item = _journeyLegs.removeAt(oldIndex);
                _journeyLegs.insert(newIndex, item);
              });
            },
            children: _journeyLegs.map((leg) {
              return ListTile(
                key: ValueKey(leg),
                title: Text("${leg.start} to ${leg.end}"),
                subtitle:
                    Text("${leg.mode}, ${leg.distance} km, ${leg.cost} Rs"),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _journeyLegs.remove(leg);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showAddJourneyLegDialog(context, setState);
          },
          child: Text('Add Journey Leg'),
        ),
      ],
    );
  }

  Widget _buildLeaveTab(
      TextEditingController controller, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Leave Type:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            _buildButton("Casual Leave", controller, setState),
            _buildButton("Commuted Leave", controller, setState),
            _buildButton("Half Pay Leave", controller, setState),
            _buildButton("Compensatory Off", controller, setState),
            _buildButton("Earned Leave", controller, setState),
            _buildButton("LWA", controller, setState),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldVisitTab() {
    return Center(
      child: Text("Field Visit details"),
    );
  }

  Widget _buildButton(
      String text, TextEditingController controller, StateSetter setState) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          controller.text = "* $text";
        });
      },
      child: Text(text),
    );
  }

  void _showAddJourneyLegDialog(BuildContext context, StateSetter setState) {
    TextEditingController _startController = TextEditingController();
    TextEditingController _endController = TextEditingController();
    TextEditingController _modeController = TextEditingController();
    TextEditingController _distanceController = TextEditingController();
    TextEditingController _costController = TextEditingController();
    bool _includeReverse = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Journey Leg"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _startController,
                decoration: InputDecoration(labelText: "From"),
              ),
              TextField(
                controller: _endController,
                decoration: InputDecoration(labelText: "To"),
              ),
              TextField(
                controller: _modeController,
                decoration: InputDecoration(labelText: "Mode of Conveyance"),
              ),
              TextField(
                controller: _distanceController,
                decoration: InputDecoration(labelText: "Distance (km)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _costController,
                decoration: InputDecoration(labelText: "Cost (Rs)"),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _includeReverse,
                    onChanged: (value) {
                      setState(() {
                        _includeReverse = value ?? false;
                      });
                    },
                  ),
                  Text("Include Reverse Journey"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Validate inputs
                if (_startController.text.isEmpty ||
                    _endController.text.isEmpty ||
                    _modeController.text.isEmpty ||
                    _distanceController.text.isEmpty ||
                    _costController.text.isEmpty) {
                  // Show error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                try {
                  setState(() {
                    _journeyLegs.add(
                      JourneyLeg(
                        start: _startController.text,
                        end: _endController.text,
                        mode: _modeController.text,
                        distance: _distanceController.text,
                        cost: _costController.text,
                      ),
                    );

                    if (_includeReverse) {
                      _journeyLegs.add(
                        JourneyLeg(
                          start: _endController.text,
                          end: _startController.text,
                          mode: _modeController.text,
                          distance: _distanceController.text,
                          cost: _costController.text,
                        ),
                      );
                    }
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any unexpected errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred: $e')),
                  );
                }
              },
              child: Text("Add"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    ).then((_) {
      _startController.dispose();
      _endController.dispose();
      _modeController.dispose();
      _distanceController.dispose();
      _costController.dispose();
    });
  }
}

class ProgressReportEntry {
  DateTime date;
  String description;

  ProgressReportEntry({required this.date, required this.description});
}

class JourneyLeg {
  String start;
  String end;
  String mode;
  String distance;
  String cost;

  JourneyLeg({
    required this.start,
    required this.end,
    required this.mode,
    required this.distance,
    required this.cost,
  });

  @override
  String toString() => "$start to $end";
}
