import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileHelper {
  Future<void> saveObjectAsFile(dynamic object, String fileName) async {
    final jsonString = jsonEncode(object);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(jsonString);
  }
}
