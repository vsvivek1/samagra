import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';

ksebButtonStyle() {
  return ButtonStyle(
    elevation: MaterialStateProperty.all<double>(2),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
    foregroundColor: MaterialStateProperty.all<Color>(ksebColor),
    overlayColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered))
        return Colors.grey.withOpacity(0.0); // Change opacity when hovered
      return Colors.transparent;
    }),

    // backgroundColor:

    //     MaterialStateProperty.all<Color>(ksebColor),
  );
}

getKsebImages() async {
  // Dio dio = Dio();

  // var images = await dio.get('https://kseb.in/uploads/Galleryitemsuppy/');
  // print(images);
  // print('image pri nting');
}

NetworkImage getKsebNetWorkImageOfDay() {
  getKsebImages();
  return NetworkImage(
    'https://kseb.in/gallerydetails/eyJpdiI6IkI2eGJ1Q1BaN1U3WmtvaVlmZkhJV2c9PSIsInZhbHVlIjoiM2FVSnp2ci9peUhtbUI5U0dLTDhZdz09IiwibWFjIjoiZTNmNmQzNDU5MDkyMjg2ZWI0MWVjNGE5ZTZiNmYwYTM0ZmIyYjk3MTU0OTI2NDQxMWQyZGU3OGE4MTJhNzM1MiIsInRhZyI6IiJ9',
  );
}
