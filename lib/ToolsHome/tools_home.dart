import 'package:flutter/material.dart';

class ToolsHomeScreen extends StatelessWidget {
  const ToolsHomeScreen({Key? key}) : super(key: key);

  void _navigateToLoadCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadCalculatorScreen()),
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

class LoadCalculatorScreen extends StatelessWidget {
  const LoadCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Calculator'),
      ),
      body: const Center(
        child: Text('This is the Load Calculator screen.'),
      ),
    );
  }
}
