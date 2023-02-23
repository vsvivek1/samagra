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
    String url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              itemCount: phoneData.length,
              itemBuilder: (context, index) {
                var data = phoneData[index];
                if (searchTerm.isNotEmpty &&
                    !data['office_name']
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase()) &&
                    !data['name']
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())) {
                  return Container();
                }
                return ListTile(
                  title: Text("${data['office_name']} - ${data['name']}"),
                  subtitle: Text(data['phone_number'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      callNumber(data['phone_number'] ?? '');
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
