import 'dart:async';

import 'package:samagra/admin/version_controller.dart';
import 'package:samagra/coming_soon.dart';
import 'package:samagra/prepare_estimate/add_new_work_form.dart';
import 'package:samagra/prepare_estimate/prepare_estimate.dart';
import 'package:samagra/samagra_home_screen/design_course_app_theme.dart';
import 'package:samagra/samagra_home_screen/models/category.dart';
import 'package:samagra/main.dart';
import 'package:flutter/material.dart';
import 'package:samagra/screens/work_selection.dart';

import 'package:samagra/frtu/frtu_inspection.dart';
import 'package:samagra/ib_booking/ib_booking.dart';
import 'package:samagra/screens/phone_book.dart';
import 'package:samagra/screens/tree_cutting_compensation.dart';
import 'package:samagra/spares_management/spares_management.dart';

class SamagraHomeMenuSelectorView extends StatefulWidget {
  const SamagraHomeMenuSelectorView({Key? key, this.callBack})
      : super(key: key);

  final Function()? callBack;
  @override
  _SamagraHomeMenuSelectorViewState createState() =>
      _SamagraHomeMenuSelectorViewState();
}

class _SamagraHomeMenuSelectorViewState
    extends State<SamagraHomeMenuSelectorView> with TickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController?.dispose();
    super.dispose();
  }

  // const DestinationScreen({Key? key}) : super(key: key);

  // Method to perform navigation
  // static void navigateTo(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => DestinationScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return GridView(
              padding: const EdgeInsets.all(8),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: List<Widget>.generate(
                Category.SamagraHomeMenuSelector.length,
                (int index) {
                  // print(Category.SamagraHomeMenuSelector[index].target);
                  // debugger(when: true);
                  final int count = Category.SamagraHomeMenuSelector.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();
                  return CategoryView(
                    callback: widget.callBack,
                    category: Category.SamagraHomeMenuSelector[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 32.0,
                crossAxisSpacing: 32.0,
                childAspectRatio: 1,
              ),
            );
          }
        },
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  int tapCount = 0;
  Timer? _timer;

  Widget getTargetWidget(target) {
    switch (target) {
      case 'WorkSelection':
        return WorkSelection();

      case 'PhoneBook':
        return PhoneBook(); // Assuming PhoneBook is another widget class
      case 'FrtuInspection':
        return ComingSoon();
        return FrtuInspection();
      case 'IbBooking':
        return IbBooking();
      case 'TreeCuttingCompensation':
        return ComingSoon();
        return TreeCuttingCompensation();
      // Add more cases as needed

      case 'VersionController':
        return VersionController();

      case 'SparesManagement':
        // return ComingSoon();
        return SparesManagement();

      case 'prepareEstimate':
        // return ComingSoon();
        return AddNewWorkForm();
        // return PrepareEstimate();
        /* else {
          return AlertDialog(
            content: Text('Dont be over smart'),
          );
        } */

        break;
      // Add more cases as needed
      default:
        return ComingSoon();
        return AddNewWorkForm();
        return ComingSoon();
      // return throw ArgumentError('Invalid target: $target');
    }
  }

  CategoryView(
      {Key? key,
      this.category,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final VoidCallback? callback;
  final Category? category;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              // onTap: category?.target(),

              onTap: () {
                print(category!.target);
                if (category!.target == 'VersionController') {
                  tapCount++;
                  print("tap count $tapCount");

                  if (tapCount == 1) {
                    _timer = Timer(Duration(minutes: 1), () {
                      // Reset the tap count if no taps occur within 1 minute
                      tapCount = 0;
                    });
                  }

                  if (tapCount == 5) {
                    // Perform your action after 5 taps
                    print('Button tapped 5 times!');
                    // Reset the tap count
                    tapCount = 0;

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return getTargetWidget(category!.target);
                      }
                          // PhoneBook

                          ),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return getTargetWidget(category!.target);
                    }
                        // PhoneBook

                        ),
                  );
                }
              },
              // onTap: () {
              //   Widget? destinationScreen = category?.target();
              //   if (destinationScreen != null) {
              //     category?.gotToTarget(context, destinationScreen);
              //   }
              // },
              child: SizedBox(
                height: 280,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#F8FAFB'),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                                // border: new Border.all(
                                //     color: DesignCourseAppTheme.notWhite),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16, left: 16, right: 16),
                                            child: Text(
                                              category!.title,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.27,
                                                color: DesignCourseAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8,
                                                left: 16,
                                                right: 16,
                                                bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                // Text(
                                                //   '${category!.lessonCount} Pending',
                                                //   textAlign: TextAlign.left,
                                                //   style: TextStyle(
                                                //     fontWeight: FontWeight.w200,
                                                //     fontSize: 12,
                                                //     letterSpacing: 0.27,
                                                //     color: DesignCourseAppTheme
                                                //         .grey,
                                                //   ),
                                                // ),
                                                // Container(
                                                //   child: Row(
                                                //     children: <Widget>[
                                                //       Text(
                                                //         '${category!.rating}',
                                                //         textAlign:
                                                //             TextAlign.left,
                                                //         style: TextStyle(
                                                //           fontWeight:
                                                //               FontWeight.w200,
                                                //           fontSize: 18,
                                                //           letterSpacing: 0.27,
                                                //           color:
                                                //               DesignCourseAppTheme
                                                //                   .grey,
                                                //         ),
                                                //       ),
                                                //       Icon(
                                                //         Icons.star,
                                                //         color:
                                                //             DesignCourseAppTheme
                                                //                 .nearlyBlue,
                                                //         size: 20,
                                                //       ),
                                                //     ],
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 48,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 24, right: 16, left: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: DesignCourseAppTheme.grey
                                      .withOpacity(0.2),
                                  offset: const Offset(0.0, 0.0),
                                  blurRadius: 6.0),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            child: AspectRatio(
                                aspectRatio: 1.28,
                                child: Hero(
                                    tag: category!.title,
                                    child: Image.asset(category!.imagePath))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
