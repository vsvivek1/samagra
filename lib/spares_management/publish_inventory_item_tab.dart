import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add Fluttertoast package

class PublishInventoryItemTab extends StatefulWidget {
  @override
  _PublishInventoryItemTabState createState() =>
      _PublishInventoryItemTabState();
}

class _PublishInventoryItemTabState extends State<PublishInventoryItemTab> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _photos = [];
  bool _isLoading = false;
  Map user1 = {};

  // Multi-select Targeted SBUs
  List<String> _selectedSBUs = ['Distribution'];
  final List<String> _sbuOptions = [
    'Distribution',
    'Transmission',
    'Generation'
  ];

  // Form Controllers for other fields
  TextEditingController _spareNameController =
      TextEditingController(text: '110 kv ct');
  TextEditingController _spareTypeController =
      TextEditingController(text: 'Breaker');
  TextEditingController _spareMakeController =
      TextEditingController(text: 'Areva');
  TextEditingController _quantityController = TextEditingController(text: '20');
  TextEditingController _locationController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _contactCugController =
      TextEditingController(text: '9847599946');
  TextEditingController _designationController = TextEditingController();
  TextEditingController _testValuesController =
      TextEditingController(text: '100');
  TextEditingController _descriptionController =
      TextEditingController(text: 'very nice');

  String _condition = 'Usable'; // Default condition

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    var user = await getUser();
    user1 = user;
    setState(() {
      _designationController.text = user['user']['seats'].firstWhere(
              (seat) => seat['mst_seat_id'] == user['user']['current_seat_id'],
              orElse: () => null)?['designation']['description'] ??
          'Designation not found';
      _contactPersonController.text = user['user']['name'];
      _locationController.text = user['user']['seats'].firstWhere(
              (seat) => seat['mst_seat_id'] == user['user']['current_seat_id'],
              orElse: () => null)?['office']['disp_name'] ??
          'Designation not found';
    });
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 1024,
      maxHeight: 768,
    );

    if (photo != null) {
      setState(() {
        _photos.add(photo);
      });
    }
  }

  Future<void> _publishSpare() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Dio dio = Dio();

        // Prepare form data with text fields
        FormData formData = FormData.fromMap({
          'targeted_sbus': _selectedSBUs,
          'spare_name': _spareNameController.text,
          'spare_type': _spareTypeController.text,
          'spare_make': _spareMakeController.text,
          'quantity_available': int.parse(_quantityController.text),
          'location': _locationController.text,
          'contact_person': _contactPersonController.text,
          'contact_cug': _contactCugController.text,
          'designation': _designationController.text,
          'test_values': _testValuesController.text,
          'description': _descriptionController.text,
          'condition': _condition,
          'uploaded_by': int.parse(await getUserId()),
          'user': jsonEncode(user1),
        });

        // Add image files to form data
        for (var photo in _photos) {
          formData.files.add(MapEntry(
            'images[]', // Add [] to the key to indicate multiple files
            await MultipartFile.fromFile(photo.path,
                filename: basename(photo.path)),
          ));
        }

        // String apiUrl = 'http://192.168.100.100:8000/api/spares';
        String apiUrl = 'http://192.168.100.100:8000/api/spares';
        print('API URL: $apiUrl');

        Response response = await dio.post(
          apiUrl,
          data: formData,
          options: Options(headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json', // Ensure server accepts JSON response
          }),
        );

        print('Response: ${response}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });

          Fluttertoast.showToast(
            msg: 'Spare published successfully!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else if (response.statusCode == 422) {
          // Handle validation error response from server
          final errorMessages =
              response.data['errors'] ?? {'error': 'Validation error'};
          _showErrorMessages(errorMessages);
          setState(() {
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to publish spare: ${response.data}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        print('Error: $e');
        Fluttertoast.showToast(
          msg: 'An error occurred: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // If form validation failed
      Fluttertoast.showToast(
        msg: 'Please fix the errors in the form.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  void _showErrorMessages(Map<String, dynamic> errors) {
    // Collect error messages from the server's response
    final errorList =
        errors.entries.map((entry) => '${entry.key}: ${entry.value}').toList();
    final errorMessage = errorList.join('\n');

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _resetForm() {
    _photos.clear();
    _selectedSBUs.clear();
    _spareNameController.clear();
    _spareTypeController.clear();
    _spareMakeController.clear();
    _quantityController.clear();
    _locationController.clear();
    _contactPersonController.clear();
    _contactCugController.clear();
    _designationController.clear();
    _testValuesController.clear();
    _descriptionController.clear();
    _condition = 'Usable';
    setState(() {});
  }

  // Widget to build image grid with card view and delete button
  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(_photos[index].path),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _photos.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget to build a text field with validation
  Widget _buildTextField(String labelText, TextEditingController controller,
      String? validationMessage,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      validator: validationMessage != null
          ? (value) => value!.isEmpty ? validationMessage : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publish Spare Item'),
        actions: [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    image: DecorationImage(
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.contain,
                      opacity: .1,
                      image: AssetImage("assets/images/backgrounds/i1.webp"),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Capture or Select Images'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _takePhoto,
                          child: Text('Take Photos'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _photos.isNotEmpty
                        ? _buildImageGrid()
                        : Text('No images captured yet'),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MultiSelectDialogField(
                            initialValue: ['Generation'],
                            items: _sbuOptions
                                .map((sbu) => MultiSelectItem(sbu, sbu))
                                .toList(),
                            title: Text('Targeted SBUs'),
                            selectedColor: Colors.blue,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border: Border.all(color: Colors.grey),
                            ),
                            buttonIcon: Icon(
                              Icons.business,
                              color: Colors.blue,
                            ),
                            buttonText: Text(
                              'Select Targeted SBUs',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onConfirm: (values) {
                              setState(() {
                                _selectedSBUs =
                                    values.map((e) => e.toString()).toList();
                              });
                            },
                            validator: (values) {
                              if (values == null || values.isEmpty) {
                                return "Please select at least one SBU";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          _buildTextField('Spare Name', _spareNameController,
                              'Please enter the spare name'),
                          _buildTextField('Spare Type', _spareTypeController,
                              'Please enter the spare type'),
                          _buildTextField('Spare Make', _spareMakeController,
                              'Please enter the spare make'),
                          _buildTextField(
                              'Quantity Available',
                              _quantityController,
                              'Please enter the quantity available',
                              keyboardType: TextInputType.number),
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
                          _buildTextField('Available Location',
                              _locationController, 'Enter location'),
                          _buildTextField('Contact Person',
                              _contactPersonController, 'Enter contact person'),
                          _buildTextField(
                              'Contact Person CUG',
                              _contactCugController,
                              'Enter contact person CUG'),
                          _buildTextField('Designation', _designationController,
                              'Enter designation'),
                          _buildTextField('Test Values (if any)',
                              _testValuesController, ''),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                          ),
                          Center(
                            child: TextButton.icon(
                              label: Text(
                                "Publish the Item",
                                textScaleFactor: 2,
                              ),
                              icon: Icon(Icons.cloud_upload),
                              onPressed: () => _publishSpare(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
