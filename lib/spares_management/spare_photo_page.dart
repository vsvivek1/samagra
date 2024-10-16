import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:samagra/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

class SparePhotoPage extends StatefulWidget {
  final String spareId; // Published item spare ID for reference
  final Function onImageUploaded;

  SparePhotoPage({required this.spareId, required this.onImageUploaded});

  @override
  _SparePhotoPageState createState() => _SparePhotoPageState();
}

class _SparePhotoPageState extends State<SparePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  List<_SparePhotoItem> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photoPaths =
        prefs.getStringList('spare_${widget.spareId}_photos') ?? [];
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
    prefs.setStringList('spare_${widget.spareId}_photos', photoPaths);
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // Set the image quality to 100 (highest)
      maxWidth: 1024, // Restrict the width of the image
      maxHeight: 768, // Restrict the height of the image
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

  Future<void> _savePhotos(BuildContext context) async {
    for (int i = 0; i < _photos.length; i++) {
      var photo = _photos[i];
      if (!photo.isSaved) {
        final response = await _uploadPhoto(photo.file);
        if (response.statusCode == 200) {
          setState(() {
            photo.isSaved = true;
            photo.serverUrl = response.data['result']
                ['location']; // URL of the uploaded image
          });

          widget.onImageUploaded(
              photo.serverUrl); // Pass the URL back to parent widget
        }
      }
    }

    await _savePhotosToLocalStorage();
  }

  Future<Response> _uploadPhoto(File photo) async {
    String fileName = basename(photo.path);
    String base64Image = base64Encode(photo.readAsBytesSync());

    Map<String, dynamic> data = {
      "source_id": widget.spareId, // Link the image to the spare part ID
      "original_doc_name": fileName,
      "encoded_document": base64Image,
      "file_format": "jpg"
    };

    Dio dio = Dio();
    String url = ""; // URL from your provided code

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

  void _deletePhoto(int index) async {
    setState(() {
      _photos[index].file.deleteSync();
      _photos.removeAt(index);
    });

    await _savePhotosToLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Spare Photos'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_upload),
            onPressed: () => _savePhotos(context),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Image.file(
                _photos[index].file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
          );
        },
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
