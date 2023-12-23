import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/environmental_config.dart';
import 'package:path_provider/path_provider.dart';

EnvironmentConfig config = EnvironmentConfig.fromEnvFile();

String nasaApiKey = config.nasaApiKey;

class NasaImageOfTheDay extends StatefulWidget {
  @override
  _NasaImageOfTheDayState createState() => _NasaImageOfTheDayState();
}

class _NasaImageOfTheDayState extends State<NasaImageOfTheDay> {
  String imageUrl = '';
  String title = '';
  String explanation = '';

  @override
  void initState() {
    super.initState();
    fetchNasaImage();
  }

  saveImageToDirectory(imageUrl) async {
    Dio dio = Dio();

    Response response = await dio.get(imageUrl,
        options: Options(responseType: ResponseType.bytes));

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDir.path}/image.jpg';

    File file = File(filePath);
    await file.writeAsBytes(response.data!); // No need for e

    // Show a message or perform other actions after saving the image
    print('Image saved to $filePath');
  }

  Future<void> fetchNasaImage() async {
    try {
      final dio = Dio();

      String url = "https://api.nasa.gov/planetary/apod?api_key=$nasaApiKey";
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          final data = response.data;
          imageUrl = data['url'];
          title = data['title'] ?? '';
          explanation = data['explanation'] ?? '';

          // saveImageToDirectory(imageUrl);
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: imageUrl.isEmpty
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Science Pic of day (NASA)'),
                    Text(
                      title,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.network(
                      imageUrl,
                      width: MediaQuery.of(context).size.width * .8,
                      height: MediaQuery.of(context).size.width * .5,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        explanation,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
