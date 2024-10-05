import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class PublishInventoryItemTab extends StatefulWidget {
  @override
  _PublishInventoryItemTabState createState() =>
      _PublishInventoryItemTabState();
}

class _PublishInventoryItemTabState extends State<PublishInventoryItemTab> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  // Form Controllers
  TextEditingController _sbuController = TextEditingController();
  TextEditingController _spareNameController = TextEditingController();
  TextEditingController _spareTypeController = TextEditingController();
  TextEditingController _spareMakeController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _contactCugController = TextEditingController();
  TextEditingController _designationController = TextEditingController();
  TextEditingController _testValuesController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _condition = 'Usable'; // Default condition

  // Image Picker from Camera
  Future<void> _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Image Picker from Gallery
  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // POST data to server
  Future<void> _publishItem() async {
    if (_formKey.currentState!.validate()) {
      FormData formData = FormData.fromMap({
        "sbu": _sbuController.text,
        "spare_name": _spareNameController.text,
        "spare_type": _spareTypeController.text,
        "spare_make": _spareMakeController.text,
        "quantity_available": _quantityController.text,
        "condition": _condition,
        "location": _locationController.text,
        "contact_person": _contactPersonController.text,
        "contact_cug": _contactCugController.text,
        "designation": _designationController.text,
        "test_values": _testValuesController.text,
        "description": _descriptionController.text,
        if (_image != null) "image": await MultipartFile.fromFile(_image!.path),
      });

      try {
        final response = await _dio.post(
            "https://your-server-api-endpoint.com/upload",
            data: formData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item published successfully!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to publish item: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Capture or Select Image"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _getImageFromCamera,
                  child: Text('Capture Photo'),
                ),
                ElevatedButton(
                  onPressed: _getImageFromGallery,
                  child: Text('Select from Gallery'),
                ),
              ],
            ),
            if (_image != null) Image.file(_image!, height: 100, width: 100),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _sbuController,
              decoration: InputDecoration(
                  labelText: 'SBU (Distribution, Transmission, Generation)'),
              validator: (value) => value!.isEmpty ? 'Enter SBU' : null,
            ),
            TextFormField(
              controller: _spareNameController,
              decoration: InputDecoration(labelText: 'Spare Name'),
              validator: (value) => value!.isEmpty ? 'Enter spare name' : null,
            ),
            TextFormField(
              controller: _spareTypeController,
              decoration: InputDecoration(labelText: 'Spare Type'),
              validator: (value) => value!.isEmpty ? 'Enter spare type' : null,
            ),
            TextFormField(
              controller: _spareMakeController,
              decoration: InputDecoration(labelText: 'Spare Make'),
              validator: (value) => value!.isEmpty ? 'Enter spare make' : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity Available'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
            ),
            DropdownButtonFormField(
              value: _condition,
              decoration: InputDecoration(labelText: 'Condition'),
              items:
                  ['Faulty', 'Damaged', 'Usable', 'Excellent'].map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _condition = value as String;
                });
              },
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Available Location'),
              validator: (value) => value!.isEmpty ? 'Enter location' : null,
            ),
            TextFormField(
              controller: _contactPersonController,
              decoration: InputDecoration(labelText: 'Contact Person'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter contact person' : null,
            ),
            TextFormField(
              controller: _contactCugController,
              decoration: InputDecoration(labelText: 'Contact Person CUG'),
              validator: (value) =>
                  value!.isEmpty ? 'Enter contact person CUG' : null,
            ),
            TextFormField(
              controller: _designationController,
              decoration: InputDecoration(labelText: 'Designation'),
              validator: (value) => value!.isEmpty ? 'Enter designation' : null,
            ),
            TextFormField(
              controller: _testValuesController,
              decoration: InputDecoration(labelText: 'Test Values (if any)'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _publishItem,
              child: Text('Publish Item'),
            ),
          ],
        ),
      ),
    );
  }
}
