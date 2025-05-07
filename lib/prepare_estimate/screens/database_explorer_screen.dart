import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseExplorerScreen extends StatefulWidget {
  final String dbPath;
  const DatabaseExplorerScreen({required this.dbPath});

  @override
  _DatabaseExplorerScreenState createState() => _DatabaseExplorerScreenState();
}

class _DatabaseExplorerScreenState extends State<DatabaseExplorerScreen> {
  List<Map<String, dynamic>> _tableInfo = [];

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    final db = await openDatabase(widget.dbPath);

    // Get all table names except system tables
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    List<Map<String, dynamic>> allTableInfo = [];

    for (var table in tables) {
      String tableName = table['name'] as String;

      // Get column info
      final columns = await db.rawQuery("PRAGMA table_info('$tableName')");

      allTableInfo.add({
        'table': tableName,
        'columns': columns,
      });
    }

    await db.close();

    setState(() {
      _tableInfo = allTableInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Tables')),
      body: _tableInfo.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tableInfo.length,
              itemBuilder: (context, index) {
                final table = _tableInfo[index];
                return ExpansionTile(
                  title: Text(
                    table['table'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: (table['columns'] as List)
                      .map<Widget>((col) => ListTile(
                            title: Text(col['name']),
                            subtitle: Text('Type: ${col['type']}'),
                          ))
                      .toList(),
                );
              },
            ),
    );
  }
}
