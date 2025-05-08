import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

Future<void> readFromSqlite() async {
  final directory = await getApplicationDocumentsDirectory();
  final dbPath = join(directory.path, 'mst_data.sqlite');

  final file = File(dbPath);
  if (!await file.exists()) {
    print('❌ Database file not found at $dbPath');
    return;
  }

  Database db = await openDatabase(dbPath);

  try {
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('Tables: $tables');

    // Replace 'your_table_name' with an actual table name from the above result
    final rows = await db.rawQuery('SELECT * FROM your_table_name');
    print('Data: $rows');
  } catch (e) {
    print('Error querying SQLite: $e');
  } finally {
    await db.close();
  }
}
