import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void openWhatsApp(String phoneNumber, String message) async {
  final Uri whatsappUrl =
      Uri.parse("whatsapp://send?phone=$phoneNumber&text=$message");
  if (await canLaunch(whatsappUrl.toString())) {
    await launch(whatsappUrl.toString());
  } else {
    // Handle the case where WhatsApp is not installed
    print("WhatsApp is not installed.");
  }
}
