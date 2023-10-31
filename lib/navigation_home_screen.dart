import 'package:samagra/app_theme.dart';
import 'package:samagra/custom_drawer/drawer_user_controller.dart';
import 'package:samagra/custom_drawer/home_drawer.dart';
import 'package:samagra/home_screen.dart';
import 'package:samagra/invite_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:samagra/screens/phone_book.dart';
import 'package:samagra/screens/tree_cutting_compensation.dart';
import 'package:samagra/screens/work_selection.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            drawerIsOpen: (p0) => true,
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const MyHomePage();
          });
          break;

        case DrawerIndex.PhoneBook:
          setState(() {
            screenView = PhoneBook();
          });
          break;

        case DrawerIndex.WorkMeasurement:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => WorkSelection()),
          );
          // setState(() {
          //   screenView = WorkSelection();
          // });
          break;

        case DrawerIndex.TreeCuttingCompensation:
          setState(() {
            screenView = TreeCuttingCompensation();
          });
          break;

        // case DrawerIndex.FeedBack:
        //   setState(() {
        //     screenView = FeedbackScreen();
        //   });
        //   break;

        case DrawerIndex.Invite:
          setState(() {
            screenView = InviteFriend();
          });
          break;
        default:
          break;
      }
    }
  }
}
