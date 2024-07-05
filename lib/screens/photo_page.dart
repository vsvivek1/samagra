import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoPage extends StatefulWidget {
  final String workCode;
  final String locationNo;

  PhotoPage({required this.workCode, required this.locationNo});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker _picker = ImagePicker();
  List<_PhotoItem> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photoPaths =
        prefs.getStringList('${widget.workCode}_${widget.locationNo}_photos') ??
            [];
    setState(() {
      _photos = photoPaths.map((path) {
        final parts = path.split('|');
        return _PhotoItem(
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
    prefs.setStringList(
        '${widget.workCode}_${widget.locationNo}_photos', photoPaths);
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = basename(photo.path);
      final String savedPath = join(appDir.path, fileName);
      final File savedImage = await File(photo.path).copy(savedPath);

      setState(() {
        _photos
            .add(_PhotoItem(file: savedImage, isSaved: false, serverUrl: ''));
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

  Future<void> _savePhotos() async {
    for (var photo in _photos) {
      if (!photo.isSaved || true) {
        final response = await _uploadPhoto(photo.file);
        if (response.statusCode == 200) {
          setState(() {
            photo.isSaved = true;
            photo.serverUrl = response.data[0];
            //.body; // assuming the server returns the URL as plain text
          });
        }
      }
    }

    await _savePhotosToLocalStorage();
  }

  Future<Response> _uploadPhoto(File photo) async {
    final String base64Image = base64Encode(photo.readAsBytesSync());
    final String fileName = basename(photo.path);

    Map<String, dynamic> data = {};
    data['source_id'] = 1;
    data['original_doc_name'] = fileName;
    data['encoded_document'] = base64Image;
    //base64Image;

    //debugger(when: true);

    Dio dio = Dio();

    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

    String url = "${config.liveServiceUrl}ext/fileupload/addFile";

    url = "https://hris.kseb.in/ipdstest/api/erp/group2/ext/fileupload/addFile";
    //'http://erpuat.kseb.in/ext/fileupload/addFile',

    try {
      var response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            // 'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Type': 'application/json',
          },
        ),
        //FormData.fromMap(data),
      );

      /*    final response = await dio.post(
        url,
        data: fileName,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      ); */

      debugger(when: true);
      return response;
    } catch (e) {
      print("Error uploading photo: $e");

      debugger(when: true);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cloud_circle_sharp),
        onPressed: _savePhotos,
        backgroundColor: Colors.green,
      ),
      appBar: AppBar(
        title: Text('Photos - ${widget.workCode} - ${widget.locationNo}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            color: Colors.green,
            icon: Icon(Icons.cloud_circle),
            onPressed: _savePhotos,
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
          return Container(
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Stack(
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
            ),
          );
        },
      ),
    );
  }
}

class _PhotoItem {
  File file;
  bool isSaved;
  String serverUrl;

  _PhotoItem({
    required this.file,
    required this.isSaved,
    required this.serverUrl,
  });
}
