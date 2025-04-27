import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> downloadDatabase() async {
  final dio = Dio();
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = '${dir.path}/mst.sqlite';

  print(dbPath);

  try {
    final response = await dio.download(
      'http://192.168.1.215:8000/api/download-sqlite-zip',
      dbPath,
    );

    print('Database downloaded to $dbPath');
  } catch (e) {
    print('Error downloading database: $e');
  }
}