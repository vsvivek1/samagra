import 'package:flutter/material.dart';
import 'package:samagra/admin/update_check.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/samagra_home_screen/samagra_home_screen.dart';
import 'package:samagra/screens/Untitled-1.dart';

class SSOLogin extends StatefulWidget {
  const SSOLogin({super.key});

  @override
  State<SSOLogin> createState() => _SSOLoginState();
}

class _SSOLoginState extends State<SSOLogin> {
  initState() {}

  @override
  Widget build(BuildContext context) {
    //return LoginScreen();

    return UpdateCheck();
    return NavigationHomeScreen();
    return SamagraHomeScreen();
    return const Placeholder();
  }
}
