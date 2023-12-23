import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class BackgroundImage extends StatelessWidget {
  final String imageUrl;
  final Widget child;

  const BackgroundImage({Key? key, required this.imageUrl, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _getImageFile(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
              child,
            ],
          );
        } else {
          return Container(); // Placeholder while loading the image
        }
      },
    );
  }

  Future<File> _getImageFile(String imageUrl) async {
    Dio dio = Dio();
    try {
      Response response = await dio.get(imageUrl,
          options: Options(responseType: ResponseType.bytes));

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/image.jpg';

      File file = File(filePath);
      await file.writeAsBytes(response.data!);

      return file;
    } catch (e) {
      print('Error downloading image: $e');
      throw e;
    }
  }
}
