import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class CapturePhotosWidget extends StatefulWidget {
  final String uuid;

  const CapturePhotosWidget({Key? key, required this.uuid}) : super(key: key);

  @override
  _CapturePhotosWidgetState createState() => _CapturePhotosWidgetState();
}

class _CapturePhotosWidgetState extends State<CapturePhotosWidget> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<String> _photosBase64 = [];  // List of Base64 encoded images

  @override
  void initState() {
    super.initState();
    _loadPhotosFromStorage();  // Load saved Base64 photos on widget load
  }

  /// Load saved Base64 photos from secure storage
  Future<void> _loadPhotosFromStorage() async {
    final storedData = await _secureStorage.read(key: 'estimates');
    if (storedData != null) {
      final Map<String, dynamic> estimates = jsonDecode(storedData);
      final estimate = estimates[widget.uuid];

      if (estimate != null && estimate['photos'] != null) {
        List<String> savedPhotos = List<String>.from(estimate['photos']);
        setState(() {
          _photosBase64 = savedPhotos;
        });
      }
    }
  }

  /// Save Base64 photos to secure storage
  Future<void> _savePhotosToStorage() async {
    final storedData = await _secureStorage.read(key: 'estimates');
    Map<String, dynamic> estimates = storedData != null ? jsonDecode(storedData) : {};

    Map<String, dynamic> estimate = estimates[widget.uuid] ?? {};

    // Save the Base64-encoded images
    estimate['photos'] = _photosBase64;

    estimates[widget.uuid] = estimate;
    await _secureStorage.write(key: 'estimates', value: jsonEncode(estimates));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photos saved successfully!')),
    );
  }

  /// Convert image file to Base64 string
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Capture a photo using the camera and save as Base64
  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      String base64Image = await _convertImageToBase64(File(photo.path));
      setState(() {
        _photosBase64.add(base64Image);
      });
      await _savePhotosToStorage();
    }
  }

  /// Pick multiple photos from the gallery and save as Base64
  Future<void> _pickPhotoFromGallery() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      for (XFile image in images) {
        String base64Image = await _convertImageToBase64(File(image.path));
        setState(() {
          _photosBase64.add(base64Image);
        });
      }
      await _savePhotosToStorage();
    }
  }

  /// Remove a photo and update storage
  void _removePhoto(int index) async {
    setState(() {
      _photosBase64.removeAt(index);
    });
    await _savePhotosToStorage();
  }

  /// Convert Base64 string back to image widget
  Widget _base64ToImage(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture or Select Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePhotosToStorage,
            tooltip: 'Save Photos',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Photo'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickPhotoFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select from Gallery'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selected Photos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _photosBase64.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _photosBase64.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _base64ToImage(_photosBase64[index]),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removePhoto(index),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const Text(
                    'No photos selected yet.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}
