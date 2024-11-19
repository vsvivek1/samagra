import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PublishCourseScreen extends StatefulWidget {
  @override
  _PublishCourseScreenState createState() => _PublishCourseScreenState();
}

class _PublishCourseScreenState extends State<PublishCourseScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-url.com/api',
    headers: {
      'Authorization': 'Bearer your_access_token',
      'Accept': 'application/json',
    },
  ));

  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {
    'title': '',
    'description': '',
    'eligibility': '',
    'start_date': '',
    'end_date': '',
    'seat_availability': '',
    'pdus': '',
  };

  Future<void> publishCourse() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      final response = await _dio.post('/courses', data: formData);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Course published successfully!")),
        );
        Navigator.pop(context); // Return to the previous screen
      }
    } catch (e) {
      print("Error publishing course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish course.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Course Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
                onSaved: (value) => formData['title'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => formData['description'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Eligibility'),
                onSaved: (value) => formData['eligibility'] = value,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                validator: (value) =>
                    value!.isEmpty ? 'Start Date is required' : null,
                onSaved: (value) => formData['start_date'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                validator: (value) =>
                    value!.isEmpty ? 'End Date is required' : null,
                onSaved: (value) => formData['end_date'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Seat Availability'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Seat availability is required' : null,
                onSaved: (value) =>
                    formData['seat_availability'] = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'PDUs (Optional)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => formData['pdus'] =
                    value != null && value.isNotEmpty ? int.parse(value) : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: publishCourse,
                child: Text("Publish"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
