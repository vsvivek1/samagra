import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneBook extends StatefulWidget {
  @override
  _PhoneBookState createState() => _PhoneBookState();
}

class _PhoneBookState extends State<PhoneBook> {
  List<dynamic> phoneData = [];
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    loadPhoneData();
  }

  loadPhoneData() async {
    String phoneDataJson = await rootBundle.loadString("assets/phone/cug.json");
    setState(() {
      phoneData = json.decode(phoneDataJson);
    });
  }

  callNumber(String number) async {
    String sanitizedNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedNumber.isNotEmpty) {
      String url = 'tel:$sanitizedNumber';
      try {
        await launch(url);
      } catch (e) {
        // Handle the error here, e.g., show a SnackBar
        showSnackBar('Error: Could not initiate the phone call');
      }
    } else {
      throw 'Invalid phone number: $number';
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredPhoneData = phoneData.where((data) {
      String officeName = data['office_name'].toLowerCase();
      String name = data['name'].toLowerCase();
      String phoneNumber = data['phone']?.toLowerCase() ?? '';
      String searchTermLowerCase = searchTerm.toLowerCase();
      return officeName.contains(searchTermLowerCase) ||
          name.contains(searchTermLowerCase) ||
          phoneNumber.contains(searchTermLowerCase);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("PhoneBook"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPhoneData.length,
              itemBuilder: (context, index) {
                var data = filteredPhoneData[index];
                return ListTile(
                  title: Text("${data['office_name']} - ${data['name']}"),
                  subtitle: Text(data['phone'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      callNumber(data['phone'] ?? '');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
