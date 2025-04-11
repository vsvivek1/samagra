import 'package:flutter/material.dart';
import 'package:samagra/screens/work_selection.dart';

class Category {
  Widget gotToTarget(BuildContext context, Widget destinationScreen) {
    // Navigate to the destination screen
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destinationScreen),
      );
    } on Exception {
      return Text('Err');
    }
    return Text('Err');
  }

  Category({
    this.title = '',
    this.imagePath = '',
    this.lessonCount = 0,
    this.money = 0,
    this.rating = 0.0,
    this.target,
  });

  String title;
  int lessonCount;
  int money;
  double rating;
  String imagePath;
  var target;

  static List<Category> categoryList = <Category>[
    Category(
      target: WorkSelection,
      imagePath: 'assets/samagra_home_screen/interFace1.png',
      title: 'Works',
      lessonCount: 24,
      money: 25,
      rating: 4.3,
    ),
    Category(
      target: WorkSelection,
      imagePath: 'assets/samagra_home_screen/interFace2.png',
      title: 'KSEB Dash Board',
      lessonCount: 22,
      money: 18,
      rating: 4.6,
    ),
    Category(
      target: WorkSelection,
      imagePath: 'assets/samagra_home_screen/interFace1.png',
      title: 'Utilities',
      lessonCount: 24,
      money: 25,
      rating: 4.3,
    ),
    Category(
      target: WorkSelection,
      imagePath: 'assets/samagra_home_screen/interFace2.png',
      title: 'My Profile',
      lessonCount: 22,
      money: 18,
      rating: 4.6,
    ),
  ];

  static List<Category> SamagraHomeMenuSelector = <Category>[
    Category(
      target: 'WorkSelection',
      imagePath: 'assets/samagra_home_screen/polevar1.jpeg',
      title: 'Polevar Measurement',
      lessonCount: 12,
      money: 25,
      rating: 4.8,
    ),
    Category(
      imagePath: 'assets/samagra_home_screen/interFace4.png',
      target: 'PhoneBook',
      title: 'Phone Book',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    /*  Category(
      imagePath: 'assets/samagra_home_screen/interFace3.png',
      target: FrtuInspection,
      title: 'RMU/FRTU inspection',
      lessonCount: 12,
      money: 25,
      rating: 4.8,
    ), */
    /*   Category(
      imagePath: 'assets/samagra_home_screen/interFace4.png',
      target: 'IbBooking',
      title: 'IB Booking',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ), */
    /*  Category(
      imagePath: 'assets/samagra_home_screen/interFace4.png',
      target: 'TreeCuttingCompensation',
      title: 'Tree Cutting Compensation',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ), */
    Category(
      imagePath: 'assets/samagra_home_screen/interFace1.png',
      target: 'VersionController',
      title: 'Admin',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),


 Category(
      imagePath: 'assets/images/electrical_drawings.webp',
      target: 'MaterialsManagement',
      title: 'Materials Demo Only',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),


    Category(
      imagePath: 'assets/images/spares_management.webp',
      target: 'SparesManagement',
      title: 'Manage Spares-Demo Only',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    Category(
      imagePath: 'assets/images/electrical_drawings.webp',
      target: 'TechnicalDocuments',
      title: 'Tech Documents  (Demo Only)',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    Category(
      imagePath: 'assets/images/helpImage.png',
      target: 'Ask',
      title: 'Ask(Demo Only)',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    Category(
      imagePath: 'assets/samagra_home_screen/prepare_estimate.webp',
      target: 'prepareEstimate',
      title: 'Prepare Estimate (Demo Only)',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    Category(
      imagePath: 'assets/images/request.webp',
      target: 'PrefilledSubmissions',
      title: 'Prefilled Forms  (Demo Only)',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
    Category(
      imagePath: 'assets/images/request.webp',
      target: 'Trainings',
      title: 'Trainings  (Demo Only)',
      lessonCount: 28,
      money: 208,
      rating: 4.9,
    ),
  ];
}
