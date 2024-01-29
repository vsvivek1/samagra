import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

String username = 'samagramobile@gmail.com';
String password = 'rbjjsxhxpdmgxbtq';

void gmailMe(dynamic object) async {
  // debugPrint()
  final smtpServer = gmail(username, password);
  //  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.

  debugPrint('hi object   $object');
  final message = Message()
    ..from = Address(username, 'from Vivek')
    ..recipients.add('vs.vivek1@gmail.com')
    // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    // ..bccRecipients.add(Address('bccAddress@example.com'))
    ..subject = 'This from samagra :: 😀 :: ${DateTime.now()}'
    // ..text = jsonEncode(object)
    ..html = jsonEncode(object);

  try {
    final sendReport = await send(message, smtpServer);
    debugPrint('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    debugPrint('Message not sent.');
    for (var p in e.problems) {
      debugPrint('Problem: ${p.code}: ${p.msg}');
    }
  }
}
