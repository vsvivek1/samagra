// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:samagra/home_screen.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _empcode = '', _password = '';
  bool _obscureText = true;

  bool _showLoginButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  _empcode = text;
                  print("Text entered: $text");
                  print("_empcode: $_empcode");
                  print("_password: $_password");

                  if (_empcode != '' && _password != '') {
                    setState(() {
                      _showLoginButton = true;
                    });
                  } else {
                    setState(() {
                      _showLoginButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'empcode',
                ),
                validator: (value) {
                  value ??= '';
                  if (value.isEmpty) {
                    return 'Please enter your empcode';
                  }
                  return null;
                },
                onSaved: (value) {
                  print(value);
                  value ??= '';
                  _empcode = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                onChanged: (t) {
                  _password = t;
                  if (_empcode != '' && _password != '') {
                    setState(() {
                      _showLoginButton = true;
                    });
                  } else {
                    setState(() {
                      _showLoginButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        })),
                obscureText: _obscureText,
                validator: (value) {
                  value ??= '';
                  if (value == '') {
                    setState(() {
                      _showLoginButton = false;
                    });

                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  // print(value);
                  value ??= '';

                  _password = value.toString();

                  print(_password);
                  print(_empcode);
                },
              ),
              SizedBox(height: 8.0),
              Visibility(
                visible: _showLoginButton,
                child: ElevatedButton(
                  onPressed: () async {
                    // print('pw1 $_password');
                    // print('code $_empcode ');

                    print('pw');
                    MyAPI api = new MyAPI();

                    String ext = "@kseberp.in";

                    String email = "$_empcode$ext";

                    // email =
                    //     "1064767@kseberp.in"; // await api.login("1040000@kseberp.in", "uat123");
                    // _password = "kseb@2108";
                    _password = "uat123";
                    Map<String, dynamic> result =
                        await api.login(email, _password);
                    print(result);

                    showAlert(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );

                    // if (_formKey.currentState.validate()) {
                    //   _formKey.currentState.save();
                    //   // Perform login
                    // }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlert(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Key press detected"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        ),
      ],
    );
    showDialog(context: context, builder: (context) => alert);
  }
}

class MyAPI {
  final String _url = "http://erpuat.kseb.in/api/login";
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Map<String, String> data = {"email": email, "password": password};

    try {
      print(_url);

      print(data);
      final Response response = await _dio.post(_url, data: data);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response);

        // print(e.response.headers);
        // print(e.response.request);
      } else {
        // print(e.request);
        print(e.message);
      }
      throw e;
    }
  }
}
