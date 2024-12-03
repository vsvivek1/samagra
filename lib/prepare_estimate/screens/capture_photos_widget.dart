import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CapturePhotosWidget extends StatefulWidget {
  @override
  _CapturePhotosWidgetState createState() => _CapturePhotosWidgetState();
}

class _CapturePhotosWidgetState extends State<CapturePhotosWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _photos = [];

  Future<void> _pickPhotoFromGallery() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _photos.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _photos.add(File(photo.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture or Select Photos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera),
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
            _photos.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.file(
                              _photos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
