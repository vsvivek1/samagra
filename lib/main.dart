import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagra/admin/update_check.dart';
import 'package:samagra/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/internet_connectivity.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/login_screen.dart';

// import 'package:samagra/spalsh_screen.dart';
// import 'navigation_home_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagra/screens/sso.dart';
import 'kseb_color.dart';

void main() async {
  // EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
  // lib/.env
  // lib/main.dart

  // .env

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
  ]).then((_) => runApp(ProviderScope(child: Samagra())));
}

methodChanel() {
  const MethodChannel channel = MethodChannel('samagra_sso');

  // Handle incoming messages from the native side
  channel.setMethodCallHandler((MethodCall call) async {
    // Handle the method call
    if (call.method == 'openScreen') {
      // Extract parameters if needed
      String screenName = call.arguments['screenName'];

      // Navigate to the specified screen in your Flutter code
      if (screenName == 'samagra_sso') {
        return MaterialPageRoute(
          builder: (context) {
            return SSO(); // Return the SSO screen with parameters if needed
          },
        );
        // Navigate to your Flutter screen
        // You may use Navigator to navigate to the desired screen
      }
    }
  });
}

class Samagra extends StatefulWidget {
  Samagra({Key? key}) : super(key: key);

  @override
  State<Samagra> createState() => _SamagraState();
}

class _SamagraState extends State<Samagra> {
  late EnvironmentConfig config;

  bool showDebugbanner = false;

  @override
  void initState() {
    super.initState();
    initializeConfigIfNeeded();
    // startJwtExpiryCheck();
    // TODO: implement initState
  }

  //

  Future<void> initializeConfigIfNeeded() async {
    config = await EnvironmentConfig.fromEnvFile();

    if (config.deploymentMode.contains('UAT')) {
      setState(() {
        showDebugbanner = true;
      });
    }
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

// return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<ConfigProvider>(create: (_) => ConfigProvider()),

// // <ConfigProvider>(
//       ],

    return PopScope(
      canPop: false,

      // onWillPop: () async {
      //   // Handle back button press logic here
      //   print('Back button pressed');
      //   return false; // Prevent back navigation
      // },
      child: MaterialApp(
        // showSemanticsDebugger: true,

        // debugShowMaterialGrid: true,
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
          // '/polevar': (context) => PolVarScreen(),
          // '/': (context) => NavigationHomeScreen(),
          '/redirected': (context) => NavigationHomeScreen(),
          '/home': (context) => NavigationHomeScreen(),
          '/sso_screen': (context) => SSO(), // SSO screen
        },
        debugShowCheckedModeBanner: showDebugbanner,
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
        home: UpdateCheck(), // //SplashScreen(),
      ),
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
