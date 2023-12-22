import 'dart:io';
import 'package:samagra/app_config.dart';
import 'package:samagra/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samagra/check_jwt_expiry.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/login_screen.dart';
// import 'package:samagra/spalsh_screen.dart';
// import 'navigation_home_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagra/screens/sso.dart';
import 'kseb_color.dart';

void main() async {
  // lib/.env
  // lib/main.dart

  // .env
  AppConfig config = await AppConfig.fromEnvFile();
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return SizedBox(
      height: 1000,
      child: Text(errorDetails.toString()),
    ); // Replace with your custom error widget
  };

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(ProviderScope(child: Samagra(appConfig: config))));
}

class Samagra extends StatefulWidget {
  var appConfig;

  Samagra({Key? key, required this.appConfig}) : super(key: key);

  @override
  State<Samagra> createState() => _SamagraState();
}

class _SamagraState extends State<Samagra> {
  @override
  void initState() {
    startJwtExpiryCheck();
    // TODO: implement initState
    super.initState();
  }

  final routes = <String, WidgetBuilder>{
    '/login': (BuildContext context) => LoginScreen(),
  };

  MaterialColor ksebMaterialColor = MaterialColor(0xFF1087A1, {
    50: Color.fromRGBO(16, 135, 161, 0.1),
    100: Color.fromRGBO(16, 135, 161, 0.2),
    200: Color.fromRGBO(16, 135, 161, 0.3),
    300: Color.fromRGBO(16, 135, 161, 0.4),
    400: Color.fromRGBO(16, 135, 161, 0.5),
    500: Color.fromRGBO(16, 135, 161, 0.6),
    600: Color.fromRGBO(16, 135, 161, 0.7),
    700: Color.fromRGBO(16, 135, 161, 0.8),
    800: Color.fromRGBO(16, 135, 161, 0.9),
    900: Color.fromRGBO(16, 135, 161, 1.0),
  });

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
      onGenerateRoute: (settings) {
        // Handle incoming deep links here
        if (settings.name == '/sso_screen') {
          // Extract parameters from the deep link
          // You might want to get the latest deep link and check its format
          // For instance, using getInitialLink() from uni_links

          return MaterialPageRoute(
            builder: (context) {
              return SSO(); // Return the SSO screen with parameters if needed
            },
          );
        }
        // Handle other routes if needed
        return null;
      },
      title: 'm-Samagra',
      initialRoute: '/',
      routes: {
        // '/': (context) => NavigationHomeScreen(),
        '/redirected': (context) => NavigationHomeScreen(),
        '/sso_screen': (context) => SSO(), // SSO screen
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        tabBarTheme: TabBarTheme(
          labelColor:
              Colors.white, // Set the text color of the selected tab to white
          unselectedLabelColor:
              ksebColor, // Set the text color of unselected tabs to grey
          indicator: BoxDecoration(
            color: ksebMaterialColor, // Set the indicator color to grey
          ),
        ),
        primarySwatch: ksebMaterialColor,
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
