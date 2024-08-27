import 'package:flutter/material.dart';
import 'package:samagra/screens/kseb_webview.dart.dart';
import 'package:samagra/screens/login_screen.dart';
import 'package:samagra/screens/phone_book.dart';
import 'package:samagra/screens/utilities_screen.dart';

class LoginScreenNavigator extends StatefulWidget {
  const LoginScreenNavigator({super.key});

  @override
  State<LoginScreenNavigator> createState() => _LoginScreenNavigatorState();
}

class _LoginScreenNavigatorState extends State<LoginScreenNavigator> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });

          if (index == 3) {
            // Assuming index 3 is for the Login screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'kseb.in',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.phone)),
            label: 'Phone',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.troubleshoot_sharp)),
            label: 'Utilities',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.login)),
            label: 'LOGIN',
          ),
        ],
      ),
      body: <Widget>[
        KsebWebView(),
        PhoneBook(),
        UtilitiesScreen(),
        Center(
            child:
                Container(width: 100, height: 100, child: Text('M samagra'))),
      ][currentPageIndex],
    );
  }
}
