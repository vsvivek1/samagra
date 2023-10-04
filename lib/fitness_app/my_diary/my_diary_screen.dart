
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/fitness_app/ui_view/mediterranean_diet_view.dart';
import 'package:samagra/fitness_app/ui_view/title_view.dart';
import 'package:samagra/fitness_app/fitness_app_theme.dart';
import 'package:flutter/material.dart';

import 'package:samagra/common.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  late String consumercount_lt;
  late String consumption_lt;
  late String demand_lt;
  late String tot_coll_count_lt;
  late String tot_coll_amt_lt;
  late String consumercount_ht;
  late String consumption_ht;
  late String demand_ht;
  late String tot_coll_count_ht;
  late String tot_coll_amt_ht;
  late String consumercount_eht;
  late String consumption_eht;
  late String demand_eht;
  late String tot_coll_count_eht;
  late String tot_coll_amt_eht;
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  Map _dashBoardData = {};

  Map _loginDetails = {};

  String _officeName = '';

  late Animation<double> animation;

  // String tot_coll_count_lt;
  // late String tot_coll_amt_lt;
  // late String consumercount_ht;
  // late String consumption_ht;
  // late String demand_ht;
  // late String tot_coll_count_ht;
  // late String tot_coll_amt_ht;
  // late String consumercount_eht;
  // late String consumption_eht;
  // late String demand_eht;
  // late String tot_coll_count_eht;
  // late String tot_coll_amt_eht;

  void assignValues(Map<String, dynamic> response) {
    consumercount_lt = response['consumercount_lt'] != null
        ? response['consumercount_lt'].toString()
        : 'No data';
    consumption_lt = response['consumption_lt'] != null
        ? response['consumption_lt'].toString()
        : 'No data';
    demand_lt = response['demand_lt'] != null
        ? response['demand_lt'].toString()
        : 'No data';
    tot_coll_count_lt = response['tot_coll_count_lt'] != null
        ? response['tot_coll_count_lt'].toString()
        : 'No data';
    tot_coll_amt_lt = response['tot_coll_amt_lt'] != null
        ? response['tot_coll_amt_lt'].toString()
        : 'No data';
    consumercount_ht = response['consumercount_ht'] != null
        ? response['consumercount_ht'].toString()
        : 'No data';
    consumption_ht = response['consumption_ht'] != null
        ? response['consumption_ht'].toString()
        : 'No data';
    demand_ht = response['demand_ht'] != null
        ? response['demand_ht'].toString()
        : 'No data';
    tot_coll_count_ht = response['tot_coll_count_ht'] != null
        ? response['tot_coll_count_ht'].toString()
        : 'No data';
    tot_coll_amt_ht = response['tot_coll_amt_ht'] != null
        ? response['tot_coll_amt_ht'].toString()
        : 'No data';
    consumercount_eht = response['consumercount_eht'] != null
        ? response['consumercount_eht'].toString()
        : 'No data';
    consumption_eht = response['consumption_eht'] != null
        ? response['consumption_eht'].toString()
        : 'No data';
    demand_eht = response['demand_eht'] != null
        ? response['demand_eht'].toString()
        : 'No data';
    tot_coll_count_eht = response['tot_coll_count_eht'] != null
        ? response['tot_coll_count_eht'].toString()
        : 'No data';
    tot_coll_amt_eht = response['tot_coll_amt_eht'] != null
        ? response['tot_coll_amt_eht'].toString()
        : 'No data';
  }

  Future<String> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');
    return Future.value(accessToken);
  }

  Future<void> getDashBoard() async {
    final _loginDetails = await getUserLoginDetails();

    Map<dynamic, dynamic> loginDetailsMap =
        _loginDetails as Map<dynamic, dynamic>;

    // print()
    _officeName = loginDetailsMap['seat_details']['office']['disp_name'];

    // print(_officeName);
    final dio = Dio();

    final url = 'http://erpuat.kseb.in/api/loadOrumaTotalDetails';

    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
    final body = {"selectkey": "HT", " mainmen": "consumercount"};

    var res = await dio.get(
      url,
      options: Options(headers: headers),
      queryParameters: body,
    );

    Map<String, dynamic> response = res.data;

    print(response.runtimeType);

    if (response['result_flag'] == 1) {
      _dashBoardData = response['result_data']['RevenueDatas']['0'];

      print(response['result_data']['RevenueDatas']['ltrevenuecat']);
      // print(_dashBoardData);

      return Future.value(_dashBoardData);
    }
  }

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    // await getDashBoard();

    // print(_dashBoardData);

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval((1 / 5) * 2, 1.0, curve: Curves.fastOutSlowIn)));
    super.initState();
  }

  void addAllListData() {
    const int count = 9;

    listViews.add(
      TitleView(
        titleTxt: this._officeName,
        // subTxt: 'Details',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
                Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    print(_dashBoardData);

    print('dashboard before list vieq');
    listViews.add(
      MediterranesnDietView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / count) * 1, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          dashBoardData: _dashBoardData),
    );

    listViews.add(AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
                  onTap: () {},
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 16, left: 16, right: 16),
                        // child: Image.asset(imagepath!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Meals today',
    //     subTxt: 'Customize',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   MealsListView(
    //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //         CurvedAnimation(
    //             parent: widget.animationController!,
    //             curve: Interval((1 / count) * 3, 1.0,
    //                 curve: Curves.fastOutSlowIn))),
    //     mainScreenAnimationController: widget.animationController,
    //   ),
    // );

    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Body measurement',
    //     subTxt: 'Today',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   BodyMeasurementView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Water',
    //     subTxt: 'Aqua SmartBottle',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //             Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   WaterView(
    //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //         CurvedAnimation(
    //             parent: widget.animationController!,
    //             curve: Interval((1 / count) * 7, 1.0,
    //                 curve: Curves.fastOutSlowIn))),
    //     mainScreenAnimationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   GlassView(
    //       animation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //           CurvedAnimation(
    //               parent: widget.animationController!,
    //               curve: Interval((1 / count) * 8, 1.0,
    //                   curve: Curves.fastOutSlowIn))),
    //       animationController: widget.animationController!),
    // );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder(
            future: getDashBoard(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              _dashBoardData = snapshot.data;
              // print(snapshot.data);
              assignValues(Map<String, dynamic>.from(snapshot.data));

              addAllListData();
              return Stack(
                children: <Widget>[
                  getMainListViewUI(),
                  getAppBarUI(),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              );
            }),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  // Widget buildAnimatedTileView(List<Map<String, dynamic>> data) {
  //   return GridView.builder(
  //     padding: EdgeInsets.all(16.0),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 16.0,
  //       mainAxisSpacing: 16.0,
  //     ),
  //     itemCount: data.length,
  //     itemBuilder: (context, index) {
  //       final animationController = AnimationController(
  //         duration: Duration(milliseconds: 500),
  //         vsync: TickerProviderStateMixin,
  //       );
  //       final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
  //         CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
  //       );
  //       animationController.forward();

  //       return AnimatedBuilder(
  //         animation: animation,
  //         builder: (BuildContext context, Widget? child) {
  //           return Opacity(
  //             opacity: animation.value,
  //             child: Transform.scale(
  //               scale: animation.value,
  //               child: _buildTile(data[index]),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildTile(Map<String, dynamic> tileData) {
    final String accCatName = tileData['acc_cat_name'];
    final int liveConsCount = tileData['live_cons_cnt'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              accCatName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '$liveConsCount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _officeName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                onTap: () {},
                                child: Center(
                                    // child: Icon(
                                    //   Icons.keyboard_arrow_left,
                                    //   color: FitnessAppTheme.grey,
                                    // ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    // child: Icon(
                                    //   Icons.calendar_today,
                                    //   color: FitnessAppTheme.grey,
                                    //   size: 18,
                                    // ),
                                  ),
                                  Text(
                                    getDateAndWeek(),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                onTap: () {},
                                child: Center(
                                    // child: Icon(
                                    //   Icons.keyboard_arrow_right,
                                    //   color: FitnessAppTheme.grey,
                                    // ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
