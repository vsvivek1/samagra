import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// class DatabaseExplorerScreen extends StatefulWidget {
//   final String dbPath;
//   const DatabaseExplorerScreen({required this.dbPath});

//   @override
//   _DatabaseExplorerScreenState createState() => _DatabaseExplorerScreenState();
// }

// class _DatabaseExplorerScreenState extends State<DatabaseExplorerScreen> {
//   List<Map<String, dynamic>> _tableInfo = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadDatabaseInfo();
//   }

//   Future<void> _loadDatabaseInfo() async {
//     final db = await openDatabase(widget.dbPath);
//     final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

//     List<Map<String, dynamic>> allTableInfo = [];

//     for (var table in tables) {
//       String tableName = table['name'] as String;
//       final columns = await db.rawQuery("PRAGMA table_info('$tableName')");
//       allTableInfo.add({
//         'table': tableName,
//         'columns': columns,
//       });
//     }

//     setState(() {
//       _tableInfo = allTableInfo;
//     });

//     await db.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Database Tables')),
//       body: _tableInfo.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _tableInfo.length,
//               itemBuilder: (context, index) {
//                 final table = _tableInfo[index];
//                 return ExpansionTile(
//                   title: Text(table['table']),
//                   children: (table['columns'] as List)
//                       .map<Widget>((col) => ListTile(
//                             title: Text(col['name']),
//                             subtitle: Text('Type: ${col['type']}'),
//                           ))
//                       .toList(),
//                 );
//               },
//             ),
//     );
//   }
// }
