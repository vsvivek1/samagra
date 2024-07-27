import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressReportScreen extends StatefulWidget {
  @override
  _ProgressReportScreenState createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  List<ProgressReportEntry> _entries = [];
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
        return Dialog(
          child: DefaultTabController(
            length: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Casual Leave"),
                    Tab(text: "Commuted Leave"),
                    Tab(text: "Half Pay Leave"),
                    Tab(text: "Compensatory Off"),
                    Tab(text: "Earned Leave"),
                    Tab(text: "LWA"),
                  ],
                ),
                Container(
                  height: 300, // Set an appropriate height
                  child: TabBarView(
                    children: [
                      _leaveTypeContent("Casual Leave", _descriptionController),
                      _leaveTypeContent(
                          "Commuted Leave", _descriptionController),
                      _leaveTypeContent(
                          "Half Pay Leave", _descriptionController),
                      _leaveTypeContent(
                          "Compensatory Off", _descriptionController),
                      _leaveTypeContent("Earned Leave", _descriptionController),
                      _leaveTypeContent("Leave Without Allowance (LWA)",
                          _descriptionController),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Enter description, journey details, etc.",
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _leaveTypeContent(String leaveType, TextEditingController controller) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            controller.text = "* $leaveType";
          });
        },
        child: Text('Select $leaveType'),
      ),
    );
  }
}

class ProgressReportEntry {
  DateTime date;
  String description;

  ProgressReportEntry({
    required this.date,
    required this.description,
  });
}
