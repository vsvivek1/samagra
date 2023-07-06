// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String message;

  const WhatsAppButton({
    required this.phoneNumber,
    required this.message,
  });

  void _openWhatsApp() async {
    final url =
        'https://api.whatsapp.com/send?phone=${Uri.encodeComponent(phoneNumber)}&text=${Uri.encodeComponent(message)}';
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch WhatsApp: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _openWhatsApp,
      child: Text('Open WhatsApp'),
    );
  }
}
