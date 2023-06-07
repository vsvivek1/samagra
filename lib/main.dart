import 'dart:io';
import 'package:samagra/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:samagra/screens/login_screen.dart';
// import 'package:samagra/spalsh_screen.dart';
// import 'navigation_home_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Text(
        errorDetails.toString()); // Replace with your custom error widget
  };

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    '/login': (BuildContext context) => LoginScreen(),
  };

  @override
  Widget build(BuildContext context) {
    InternetConnectivity.showInternetConnectivityToast(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'm-Samagra',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: LoginScreen(), // //SplashScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
