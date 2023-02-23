// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Square Tiles Demo',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Square Tiles Demo'),
//         ),
//         body: SchGrpListWidget(jsonData['result_data']['schGrpList']),
//       ),
//     );
//   }
// }

// class SchGrpListWidget extends StatelessWidget {
//   final List schGrpList;

//   SchGrpListWidget(this.schGrpList);

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1,
//       ),
//       itemCount: schGrpList.length,
//       itemBuilder: (context, index) {
//         final item = schGrpList[index];
//         return GridTile(
//           child: Container(
//             color: Colors.blueGrey,
//             child: Center(
//               child: Text(item['wrk_work_detail']['work_name']),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
