import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class UploadDocumentScreen extends StatefulWidget {
  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  String selectedCompany = 'NA';
  List<String> companies = ['NA', 'Company A', 'Company B', 'Company C'];
  PlatformFile? selectedFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  void _uploadFile() async {
    if (selectedFile == null || selectedCompany == 'NA') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a file and a company")),
      );
      return;
    }

    try {
      String fileName = selectedFile!.name;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(selectedFile!.path!,
            filename: fileName),
        "company_name": selectedCompany,
      });

      Dio dio = Dio();
      Response response =
          await dio.post("https://yourapi.com/api/documents", data: formData);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File uploaded successfully")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("File upload failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCompany,
              items: companies.map((String company) {
                return DropdownMenuItem<String>(
                  value: company,
                  child: Text(company),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCompany = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Choose File'),
            ),
            if (selectedFile != null)
              Text('Selected File: ${selectedFile!.name}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
