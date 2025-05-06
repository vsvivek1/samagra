import 'package:flutter/material.dart';
import 'package:samagra/ToolsHome/load_calculator.dart';

class ToolsHomeScreen extends StatelessWidget {
  const ToolsHomeScreen({Key? key}) : super(key: key);

  void _navigateToLoadCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  LoadCalculatorApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _navigateToLoadCalculator(context),
          child: const Text('Load Calculator'),
        ),
      ),
    );
  }
}


