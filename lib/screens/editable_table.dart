import 'package:flutter/material.dart';

class EditableTable<T> extends StatefulWidget {
  final List<T> data;
  final List<String> headers;

  EditableTable({required this.data, required this.headers});

  @override
  _EditableTableState<T> createState() => _EditableTableState<T>();
}

class _EditableTableState<T> extends State<EditableTable<T>> {
  late List<Map<String, dynamic>> rows;
  // late List rows;

  @override
  void initState() {
    super.initState();
    rows = widget.data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: widget.headers
            .map((e) => DataColumn(
                  label: Text(e),
                ))
            .toList(),
        rows: rows.map((e) => DataRow(cells: _getCells(e))).toList(),
      ),
    );
  }

  List<DataCell> _getCells(Map<String, dynamic> row) {
    return row.entries
        .map((e) => DataCell(
              TextFormField(
                initialValue: e.value.toString(),
                onChanged: (value) {
                  setState(() {
                    row[e.key] = value;
                  });
                },
              ),
            ))
        .toList();
  }
}
