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

class PublishInventoryItemTab extends StatefulWidget {
  @override
  _PublishInventoryItemTabState createState() =>
      _PublishInventoryItemTabState();
}

class _PublishInventoryItemTabState extends State<PublishInventoryItemTab> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<_SparePhotoItem> _photos = [];
  List<String> _uploadedImageUrls = []; // Store the URLs of uploaded images
  bool _isLoading = false;
  bool _photosUploaded = false; // Control visibility of other fields
  String _uploadStatus = ''; // Text to show upload progress

  // Multi-select Targeted SBUs
  List<String> _selectedSBUs = [];
  final List<String> _sbuOptions = [
    'Distribution',
    'Transmission',
    'Generation'
  ];

  // Form Controllers for other fields
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

  // Additional Fields
  String _condition = 'Usable'; // Default condition
  late Map user1; // = {};
  @override
  void initState() {
    super.initState();
    _loadPhotos();
    ;
  }

  @override
  void dispose() {
    _spareNameController.dispose();
    _spareTypeController.dispose();
    _spareMakeController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _contactPersonController.dispose();
    _contactCugController.dispose();
    _designationController.dispose();
    _testValuesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    user1 = await getUser();

    /// to load users
    final prefs = await SharedPreferences.getInstance();
    final photoPaths = prefs.getStringList('spare_photos') ?? [];
    setState(() {
      _photos = photoPaths.map((path) {
        final parts = path.split('|');
        return _SparePhotoItem(
          file: File(parts[0]),
          isSaved: parts[1] == 'true',
          serverUrl: parts.length > 2 ? parts[2] : '',
        );
      }).toList();
    });
  }

  Future<void> _savePhotosToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final photoPaths = _photos.map((photo) {
      return '${photo.file.path}|${photo.isSaved}|${photo.serverUrl}';
    }).toList();
    prefs.setStringList('spare_photos', photoPaths);
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // Highest quality
      maxWidth: 1024, // Restrict width
      maxHeight: 768, // Restrict height
    );

    if (photo != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = basename(photo.path);
      final String savedPath = join(appDir.path, fileName);
      File savedImage = await File(photo.path).copy(savedPath);

      setState(() {
        _photos.add(
            _SparePhotoItem(file: savedImage, isSaved: false, serverUrl: ''));
      });

      await _savePhotosToLocalStorage();
    }
  }

  void _deletePhoto(int index) async {
    setState(() {
      _photos[index].file.deleteSync();
      _photos.removeAt(index);
    });

    await _savePhotosToLocalStorage();
  }

  Future<void> _uploadPhotos() async {
    bool allUploaded = true;
    _uploadedImageUrls.clear(); // Clear previously uploaded image URLs

    setState(() {
      _uploadStatus = 'Uploading 0 of ${_photos.length} photos...';
    });

    for (int i = 0; i < _photos.length; i++) {
      var photo = _photos[i];
      if (!photo.isSaved) {
        final response = await _uploadPhoto(photo.file);
        if (response.statusCode == 200) {
          setState(() {
            photo.isSaved = true;
            photo.serverUrl = response.data['result']
                ['location']; // URL of the uploaded image
            _uploadedImageUrls.add(photo.serverUrl); // Store the uploaded URL
          });
        } else {
          allUploaded = false;
        }

        setState(() {
          _uploadStatus = 'Uploading ${i + 1} of ${_photos.length} photos...';
        });
      }
    }

    if (allUploaded) {
      setState(() {
        _photosUploaded = true;
        _uploadStatus = 'All photos uploaded successfully!';
      });
    } else {
      setState(() {
        _uploadStatus = 'Failed to upload some photos. Try again.';
      });
    }

    await _savePhotosToLocalStorage();
  }

  Future<Response> _uploadPhoto(File photo) async {
    String fileName = basename(photo.path);
    String base64Image = base64Encode(photo.readAsBytesSync());

    Map<String, dynamic> data = {
      "source_id": 1, // Use appropriate source ID if needed
      "original_doc_name": fileName,
      "encoded_document": base64Image,
      "file_format": "jpg"
    };

    Dio dio = Dio();
    String url = "";

    // Load environment configuration
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

    if (config.deploymentMode == 'MOD_PRODUCTION_SSO') {
      url = "https://ws.kseb.in/resource/api/erp/group2/ext/fileupload/addFile";
    } else {
      url =
          "https://hris.kseb.in/ipdstest/api/erp/group2/ext/fileupload/addFile";
    }

    Response response = await dio.post(
      url,
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return response;
  }

  Future<void> _publishSpare() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Add image URLs to form data
      Map<String, dynamic> formData = {
        'targeted_sbus': _selectedSBUs, // Use the selected SBUs
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
        'images': _uploadedImageUrls,
        'uploaded_by': int.parse(await getUserId()),

        // Attach the uploaded image URLs
      };

      try {
        Dio dio = Dio();
        String apiUrl2 =
            "http://192.168.1.215:8000/api/spares"; // Replace with your API URL

        String apiUrl = 'http://192.168.1.215:8000/api/test';
        String apiUrl3 = 'http://192.168.100.108:8000/api/spares';

        apiUrl = apiUrl3;
        print(apiUrl);
        Response response = await dio.post(
          apiUrl,
          data: formData,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        print(response);

        debugger(when: true);

        if (response.statusCode == 201 || response.statusCode == 200) {
          setState(() {
            _uploadStatus = 'Spare published successfully!';
          });
          _resetForm();
        } else {
          throw Exception('Failed to publish spare');
        }
      } catch (e) {
        setState(() {
          print(e);
          _uploadStatus = 'Error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _photos.clear();
    _uploadedImageUrls.clear();
    _selectedSBUs.clear(); // Reset SBUs
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
    setState(() {
      _photosUploaded = false; // Hide form fields after reset
      _uploadStatus = ''; // Clear status message
    });
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
                  _photos[index].file,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePhoto(index),
                ),
              ),
              if (_photos[index].isSaved)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(
                    Icons.cloud_done,
                    color: Colors.green,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Capture and Display Section
                  Text('Capture or Select Images'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _takePhoto,
                        child: Text('Take Photos'),
                      ),
                      ElevatedButton(
                        onPressed: _uploadPhotos,
                        child: Text('Upload Photos'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _photos.isNotEmpty
                      ? _buildImageGrid()
                      : Text('No images captured yet'),
                  SizedBox(height: 20),

                  // Status text for uploading
                  if (_uploadStatus.isNotEmpty)
                    Center(
                      child: Text(
                        _uploadStatus,
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),

                  // Only show this section after photos are uploaded
                  if (_photosUploaded)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Multi-select for Targeted SBUs
                          MultiSelectDialogField(
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

                          // Other form fields
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

                          if (_photosUploaded)
                            Center(
                              child: TextButton.icon(
                                label: Text(
                                  "Publish the Item",
                                  textScaleFactor: 2,
                                ),
                                icon: Icon(Icons.cloud_upload),
                                onPressed: () =>
                                    _publishSpare(), // Publish the spare part
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SparePhotoItem {
  File file;
  bool isSaved;
  String serverUrl;

  _SparePhotoItem({
    required this.file,
    required this.isSaved,
    required this.serverUrl,
  });
}
