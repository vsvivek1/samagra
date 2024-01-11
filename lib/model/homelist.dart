import 'package:flutter/widgets.dart';
import 'package:samagra/samagra_home_screen/samagra_home_screen.dart';
import 'package:samagra/screens/work_selection.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
    this.text = '',
  });

  Widget? navigateScreen;
  String imagePath;
  String text;

  static List<HomeList> homeList = [
    HomeList(
      text: 'Work Measurement',
      imagePath: 'assets/measurement_app/mbook.jpeg',
      navigateScreen: WorkSelection(),
    ),
    HomeList(
      imagePath: 'assets/hotel/hotel_booking.png',
      navigateScreen: SamagraHomeScreen(),
    ),
    HomeList(
      imagePath: 'assets/fitness_app/fitness_app.png',
      // navigateScreen: FitnessAppHomeScreen(),
    ),
    HomeList(
      imagePath: 'assets/design_course/design_course.png',
      // navigateScreen: DesignCourseHomeScreen(),
    ),
  ];
}
