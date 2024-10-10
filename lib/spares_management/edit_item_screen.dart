import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  EditItemScreen({required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  File? _image;
  final picker = ImagePicker();
  final Dio _dio = Dio();

  // Form Controllers (initialize with existing values)
  late TextEditingController _sbuController;
  late TextEditingController _spareNameController;
  late TextEditingController _spareTypeController;
  late TextEditingController _spareMakeController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactCugController;
  late TextEditingController _designationController;
  late TextEditingController _testValuesController;
  late TextEditingController _descriptionController;

  String _condition = 'Usable'; // Default condition

  @override
  void initState() {
    super.initState();
    _sbuController = TextEditingController(text: widget.item['sbu']);
    _spareNameController =
        TextEditingController(text: widget.item['spare_name']);
    _spareTypeController =
        TextEditingController(text: widget.item['spare_type']);
    _spareMakeController =
        TextEditingController(text: widget.item['spare_make']);
    _quantityController =
        TextEditingController(text: widget.item['quantity_available']);
    _locationController = TextEditingController(text: widget.item['location']);
    _contactPersonController =
        TextEditingController(text: widget.item['contact_person']);
    _contactCugController =
        TextEditingController(text: widget.item['contact_cug']);
    _designationController =
        TextEditingController(text: widget.item['designation']);
    _testValuesController =
        TextEditingController(text: widget.item['test_values']);
    _descriptionController =
        TextEditingController(text: widget.item['description']);
    _condition = widget.item['condition'] ?? 'Usable';
  }

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

  // Function to save the edited item to the server
  Future<void> _saveEdit() async {
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
      final response = await _dio.put(
          "https://your-server-api-endpoint.com/items/${widget.item['id']}",
          data: formData);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item updated successfully!')));
        Navigator.pop(context); // Go back to listings
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
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
              if (_image != null)
                Image.file(_image!, height: 100, width: 100)
              else if (widget.item['image'] != null)
                Image.network(widget.item['image'], height: 100, width: 100),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _sbuController,
                decoration: InputDecoration(
                    labelText: 'SBU (Distribution, Transmission, Generation)'),
              ),
              TextFormField(
                controller: _spareNameController,
                decoration: InputDecoration(labelText: 'Spare Name'),
              ),
              TextFormField(
                controller: _spareTypeController,
                decoration: InputDecoration(labelText: 'Spare Type'),
              ),
              TextFormField(
                controller: _spareMakeController,
                decoration: InputDecoration(labelText: 'Spare Make'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity Available'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField(
                value: _condition,
                decoration: InputDecoration(labelText: 'Condition'),
                items: ['Faulty', 'Damaged', 'Usable', 'Excellent']
                    .map((condition) {
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
              ),
              TextFormField(
                controller: _contactPersonController,
                decoration: InputDecoration(labelText: 'Contact Person'),
              ),
              TextFormField(
                controller: _contactCugController,
                decoration: InputDecoration(labelText: 'Contact Person CUG'),
              ),
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(labelText: 'Designation'),
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
                onPressed: _saveEdit,
                child: Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
