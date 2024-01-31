import 'package:flutter/material.dart';

class CurvedTextFab extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CurvedTextFab({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          child: Icon(Icons.add),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipPath(
            clipper: CurvedTextClipper(),
            child: Container(
              color: Colors.blue, // Adjust color as needed
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CurvedTextClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: CurvedTextFab(
//         text: 'Your Curved Text Here',
//         onPressed: () {
//           // Add your button's onPressed logic here
//         },
//       ),
//     ),
//   ));
// }
