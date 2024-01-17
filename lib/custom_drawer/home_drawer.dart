import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:samagra/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'dart:convert';

import 'package:samagra/secure_storage/common_functions.dart';
import 'package:samagra/environmental_config.dart';

late EnvironmentConfig config;

Future<void> initializeConfigIfNeeded() async {
  config = await EnvironmentConfig.fromEnvFile();
  // if (config == null) {
  //   config = await EnvironmentConfig.fromEnvFile();
  // }
}

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {Key? key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;

  dynamic _loginDetails1;
  late Map<String, String> _User;
  // late Map<String, String> _loginDetails;

  //  final SecureStorage _secureStorage = SecureStorage();

  var _secureStorage = SecureStorage();
  @override
  void initState() {
    initializeConfigIfNeeded();
    setDrawerListArray();

    super.initState();
  }

  Future<Object> _getUserLoginDetails() async {
    _loginDetails1 =
        await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

    if (_loginDetails1 != null &&
        _loginDetails1["loginDetails"] != null &&
        isJson(_loginDetails1["loginDetails"])) {
      // var ob = _loginDetails1["loginDetails"];
      var ob = json.decode(_loginDetails1["loginDetails"]);

      ob["seat_details"] =
          this.getCurrentSeatDetails(_loginDetails1["loginDetails"]);

      return Future.value(ob);
    } else {
      var ob = {};

      ob["seat_details"] = '';

      return Future.value(ob);
    }
  }

  Map setCurrentSeatDetails(loginDeatails1, seatId) {
    Map loginDetails = json.decode(loginDeatails1);

    int currentSeatId = loginDetails['user']!['current_seat_id'] ?? -1;

    if (currentSeatId != -1) {
      loginDetails['user']['current_seat_id'] = seatId;
    }

    return this.getCurrentSeatDetails(loginDeatails1);
  }

  Map getCurrentSeatDetails(loginDeatails1) {
    Map loginDetails = json.decode(loginDeatails1);

    int currentSeatId = loginDetails['user']!['current_seat_id'] ?? -1;

    var seats = loginDetails['user']!['seats'] ?? [];

    if (seats == []) {
      return {};
    }

    Map<String, dynamic> selectedSeat = seats.firstWhere(
      (seat) => seat['mst_seat_id'] == currentSeatId,
      orElse: () => null,
    );

    return selectedSeat;
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Home',
        icon: Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.PhoneBook,
        labelName: 'Phone Book',
        isAssetsImage: true,
        imageName: 'assets/images/supportIcon.png',
      ),
      DrawerList(
        index: DrawerIndex.WorkMeasurement,
        labelName: 'Work Measurement',
        isAssetsImage: true,
        imageName: 'assets/images/supportIcon.png',
      ),
      DrawerList(
        index: DrawerIndex.IbBooking,
        labelName: 'Ib Booking',
        isAssetsImage: true,
        imageName: 'assets/images/supportIcon.png',
      ),
      DrawerList(
        index: DrawerIndex.TreeCuttingCompensation,
        labelName: 'TreeCuttingCompensation',
        icon: Icon(
          Icons.forest,
          color: Color.fromARGB(255, 2, 56, 30),
        ),
      ),
      DrawerList(
        index: DrawerIndex.FrtuInspection,
        labelName: 'RMU/FRTU Inspection',
        icon: Icon(
          Icons.loop_outlined,
          color: Color.fromARGB(255, 2, 56, 30),
        ),
      ),
      // DrawerList(
      //   index: DrawerIndex.Invite,
      //   labelName: 'Invite Friend',
      //   icon: Icon(Icons.group),
      // ),
      // DrawerList(
      //   index: DrawerIndex.Share,
      //   labelName: 'Rate the app',
      //   icon: Icon(Icons.share),
      // ),
      // DrawerList(
      //   index: DrawerIndex.About,
      //   labelName: 'About Us',
      //   icon: Icon(Icons.info),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppTheme.notWhite.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 -
                            (widget.iconAnimationController!.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(
                                      begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(
                                      parent: widget.iconAnimationController!,
                                      curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: AppTheme.grey.withOpacity(0.6),
                                    offset: const Offset(2.0, 4.0),
                                    blurRadius: 8),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(60.0)),
                              child: FutureBuilder(
                                  future: _getUserLoginDetails(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data['user'] != null) {
                                      var login = Map<String, dynamic>.from(
                                          snapshot.data);

                                      var user = login["user"];
                                      var dp = user['photo_image'];

                                      // debugger(when: true);
                                      Uint8List imageBytes;
                                      // base64Decode('jjjj');
                                      if (dp == null) {
                                        String dummyBase64String =
                                            "R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="; // 1x1 transparent GIF
                                        List<int> dummyBytes =
                                            base64Decode(dummyBase64String);
                                        imageBytes =
                                            Uint8List.fromList(dummyBytes);
                                      } else {
                                        imageBytes = base64Decode(dp);
                                      }

                                      return Image.memory(imageBytes);
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: FutureBuilder(
                        future: _getUserLoginDetails(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data['user'] != null &&
                              snapshot.data['user']['seat_details'] != '') {
                            var login =
                                Map<String, dynamic>.from(snapshot.data);

                            var user = login["user"];

                            Map seatDetails = login['seat_details'];

                            // p(seatDetails);

                            // p('saeat details abobve');

                            String userName = user["name"];

                            String officeId =
                                seatDetails['office_id'].toString();

                            int employeeCode = user["employee_code"];

                            String designation =
                                user["designation"]["description"];

                            String CurrentSeatCode = seatDetails['seat_code'];

                            return Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isLightMode
                                                ? AppTheme.grey
                                                : AppTheme.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 10, width: 10),
                                        Text(
                                          employeeCode.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            color: isLightMode
                                                ? AppTheme.grey
                                                : AppTheme.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          designation,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            color: isLightMode
                                                ? AppTheme.grey
                                                : AppTheme.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(height: 10, width: 10),
                                        Text(
                                          CurrentSeatCode,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            color: isLightMode
                                                ? AppTheme.grey
                                                : AppTheme.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Text(
                                    //   _getCurrentSeatDetailsFromSeatsArray(
                                    //           jsonMap["user"]["seats"],
                                    //           jsonMap["user"]
                                    //               ["current_seat_id"])
                                    //       .toString(),
                                    //   style: TextStyle(
                                    //     fontWeight: FontWeight.w600,
                                    //     color: isLightMode
                                    //         ? AppTheme.grey
                                    //         : AppTheme.white,
                                    //     fontSize: 10,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                Text(
                                  user["lien_office"]["disp_name"] +
                                      ' ' +
                                      officeId,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: isLightMode
                                        ? AppTheme.grey
                                        : AppTheme.white,
                                    fontSize: 15,
                                  ),
                                ),
                                // Text(
                                //   user["name"],
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //     color: isLightMode
                                //         ? AppTheme.grey
                                //         : AppTheme.white,
                                //     fontSize: 15,
                                //   ),
                                // ),

                                createSelectionBox(
                                    user["seats"],
                                    user["seats"]
                                        [0]), //change with current object
                              ],
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () {
                  logOut();

                  onTapped();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }

  Object _getCurrentSeatDetailsFromSeatsArray(seats, currentSeatId) {
    return 'hi';

    print(seats
        .firstWhere((seat) => seat["mst_seat_id"] == currentSeatId)
        .runtimeType);
    // print(currentSeatId);

    // return 'hi';
    // // return seats[0];

    return seats.firstWhere((seat) => seat["mst_seat_id"] == currentSeatId);
  }

  void logOut() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
  }

  // final String _url = "config.liveServiceUrlswitchUserSeat";
  final String _url = "${config.liveServiceUrl}switchUserSeat";
  final Dio _dio = new Dio();
// final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  Future<Map> switchUserRoles(String seatId) async {
    try {
      final Map<String, dynamic> data = {
        'seat_id': seatId,
      };

      Map accessToken1 =
          await _secureStorage.getSecureAllStorageDataByKey("access_token");

      // p(seatId);

      String accessToken = accessToken1['access_token'];

      final response = await _dio.post(_url,
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer  $accessToken",
          }));

      final result = response.data;

      // p(result.toString());

      return Future.value(data);

      // p(result["result_data"]["access_token"]);
      // p(result["result_data"]);

      // Store the data in secure storage
      await _secureStorage.writeKeyValuePairToSecureStorage(
          "access_token", result["result_data"]["access_token"]);

      await _secureStorage.writeKeyValuePairToSecureStorage(
          'loginDetails', jsonEncode(result['result_data']));

      return result;
    } catch (e) {
      throw Exception("Failed to switch user roles: $e");
    }
  }

  String getInitials(String name) {
    try {
      // p(name);
      if (name.isEmpty) {
        return '';
      }
      List<String> words = name.split(' ');
      String initials = '';

      if (words.length == 0) {
        return '';
      }

      return words[0];
      // for (int i = 0; i < words.length - 1; i++) {
      //   initials += words[i][0];
      // }
      // initials = initials + '-' + words.last.substring(0, 3);
      // return initials.toUpperCase();
    } on Exception {
      // TODO

      return name;
    }
  }

  DropdownButton createSelectionBox(List items, Object selectedItem,
      {String hint = 'Change to Switch Seats/Roles'}) {
    bool switchingInProgress = false;

    return DropdownButton(
      value: selectedItem,
      hint: Row(
        children: [
          if (switchingInProgress) CircularProgressIndicator(),
          Text(hint),
        ],
      ),
      items: items.map((item) {
        return DropdownMenuItem<dynamic>(
          value: item,
          child: SingleChildScrollView(
              child: Text(item["seat_code"] +
                  ' ' +
                  ' of ' +
                  getInitials(item["office"]["disp_name"]))),
        );
      }).toList(),
      onChanged: (newValue) async {
        setState(() {
          switchingInProgress = true;
        });

        try {
          var loginDetails =
              await switchUserRoles(newValue["mst_seat_id"].toString());

          setState(() {
            switchingInProgress = false;
            selectedItem = newValue;
          });

          await _secureStorage.writeKeyValuePairToSecureStorage("access_token",
              loginDetails["result_data"]["token"]["access_token"]);

          await _secureStorage.writeKeyValuePairToSecureStorage(
              "login_details", json.encode(loginDetails));
        } catch (e) {
          setState(() {
            switchingInProgress = false;
          });
        }
      },
    );
  }

  void onTapped() {
    print('Doing Something...'); // Print to console.
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              ksebColor), // Replace with your desired background color
                        ),
                        onPressed: (() {}),
                        child: Text('works')),
                  ),
                  Container(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Colors.blue
                                  : AppTheme.nearlyBlack),
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index
                              ? Colors.blue
                              : AppTheme.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Colors.black
                          : AppTheme.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) *
                                (1.0 -
                                    widget.iconAnimationController!.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  WorkMeasurement,
  IbBooking,
  TreeCuttingCompensation,
  Help,
  Share,
  About,
  Invite,
  Testing,
  PhoneBook,
  FrtuInspection
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
