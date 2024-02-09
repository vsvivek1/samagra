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
