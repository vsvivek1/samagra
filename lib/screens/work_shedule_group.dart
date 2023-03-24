import 'package:flutter/material.dart';

class WorkScheduleGroup extends StatefulWidget {
  final List<Map<String, dynamic>> entries;

  const WorkScheduleGroup({Key? key, required this.entries}) : super(key: key);

  @override
  _WorkScheduleGroupState createState() => _WorkScheduleGroupState();
}

class _WorkScheduleGroupState extends State<WorkScheduleGroup> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.entries.length,
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  entry['isExpanded'] = !(entry['isExpanded'] ?? false);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry['task_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      entry['isExpanded'] ?? false
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
            if (entry['isExpanded'] ?? false)
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in entry['items'])
                      Row(
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                item['quantity'] = (item['quantity'] ?? 0) + 1;
                              });
                            },
                            child: Text('+'),
                          ),
                          SizedBox(width: 5),
                          Text(
                            (item['quantity'] ?? 0).toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                item['quantity'] = (item['quantity'] ?? 0) - 1;
                              });
                            },
                            child: Text('-'),
                          ),
                        ],
                      ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
