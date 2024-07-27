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
          if (index == 2) {
            // Assuming index 2 is for the special case
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }

          setState(() {
            currentPageIndex = index;
          });
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

          /*    NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ), */
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.login),
            ),
            label: 'LOGIN',
          ), /*  NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.messenger_sharp),
            ),
            label: 'Messages',
          ), */
        ],
      ),
      body: <Widget>[
        KsebWebView(),

        /// Home page
        /*   Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ), */

        PhoneBook(),

        /// Notifications page
        /*    const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),
 */
        /// Messages page
        ///
        ///
        ///
        ///
        ///

        UtilitiesScreen(),

        Center(
            child:
                Container(width: 100, height: 100, child: Text('M samagra'))),
        // LoginScreen(),
        /*   ListView.builder(
          reverse: true,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hello',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hi!',
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            );
          },
        ),
      */
      ][currentPageIndex],
    );
  }
}
