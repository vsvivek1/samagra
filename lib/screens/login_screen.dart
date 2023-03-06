// import 'dart:html';

// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:samagra/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:samagra/app_theme.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'dart:convert';

import '../internet_connectivity.dart';

// import 'package:samagra/secure_storage/common_functions.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Dio _dio = Dio();

  final SecureStorage _secureStorage = SecureStorage();
  String _empcode = '', _password = '';
  bool _obscureText = true;

  bool _showLoginButton = false;
  bool _rememberMe = true;
  int _isLoggingIn = 0;
  String _loginError = ' ';
  var _isValidUsername;
  // TextEditingController _usernameController = new TextEditingController();

  TextEditingController _usernameController = TextEditingController();

  var username;

  // String access_token;

  bool _empCodeValidator = false;
  String empCodeInitialValue = '';
  String passwordInitialValue = '';

  bool _showFirstTimePasswordFeild = false;

  get _showFirstTimePasswordField => _showFirstTimePasswordFeild;
  //  bool _showFirstTimePasswordField;

  @override
  void initState() {
    super.initState();

    if (_showFirstTimePasswordFeild) {
      // show the spinning icon for 2 seconds and then show the password field
      Timer(Duration(seconds: 1), () {
        setState(() {
          _showFirstTimePasswordFeild = true;
        });
      });
    }
  }

  Future<Object> _getUserLoginDetails() async {
    var loginDetails1 =
        await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

    if (!loginDetails1?.isEmpty && loginDetails1["loginDetails"] != null) {
      var ob = json.decode(loginDetails1["loginDetails"] ?? '');

      // ob["seat_details"] =
      //     this.getCurrentSeatDetails(_loginDetails1["loginDetails"]);

      return Future.value(ob);
    } else {
      var ob = {};

      ob["seat_details"] = '';

      return Future.value(ob);
    }
  }

  Future<String> _getSavedUsernameAndPassword() async {
    var _loginDetails1 =
        await _secureStorage.getSecureAllStorageDataByKey('storedLogin');

    if (_loginDetails1.containsKey("storedLogin")) {
      dynamic empCodeObj = jsonDecode(_loginDetails1["storedLogin"]);

      String empcode = empCodeObj["login"].split(RegExp(r'@'))[0];

      String password = jsonDecode(_loginDetails1["storedLogin"])["password"];

      // print(empcode);

      _empcode = empcode;
      _password = password;

      return _loginDetails1["storedLogin"];
    } else {
      _loginDetails1["storedLogin"] = '';
    }
    _showLoginButton = true;

    return _loginDetails1["storedLogin"];

    // if (_loginDetails1["storedLogin"] != null) {
    //   setState(() {
    //     _showLoginButton = true;
    //   });
    // }
    //.toString();
  }

  Future<String> _setSavedUserNameAndPassword(
      String login, String password) async {
    var data = {"login": login, "password": password};
    var dataJson = jsonEncode(data);

    await _secureStorage.writeKeyValuePairToSecureStorage(
        'storedLogin', dataJson);

    return '1';
    // return _loginDetails1["storedLogin"]; //.toString();
  }

  @override
  Widget build(BuildContext context) {
    InternetConnectivity.showInternetConnectivityToast(context);
    // print("this is is logging in $_isLoggingIn");

    if (_isLoggingIn == -2) {
      return createLoadingSpinner();
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: FutureBuilder(
                  future: _getSavedUsernameAndPassword(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print(snapshot.data);

                    if (!(snapshot.hasData &&
                        snapshot.data.runtimeType == 'String')) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 200, left: 20, right: 20),
                          child: Column(children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('assets/images/kseb_emblem.jpeg'),
                            ),
                            SizedBox(height: 20, width: 20),
                            showUserNameForm1(),
                          ]),
                        ),
                      );
                    } else {
                      // if (snapshot.data.runtimeType != 'String') {
                      //   return Text('na');
                      // }
                      var loginDetails = json.decode(snapshot.data);

                      passwordInitialValue = loginDetails!['password'] ?? '';

                      print(passwordInitialValue);
                      // _inittializeLoginCredentials(snapshot);

                      // if (snapshot.data != null &&
                      //     jsonDecode(snapshot.data) != null) {
                      //   if ((jsonDecode(snapshot.data)['login'] != null)) {
                      //     _empcode = jsonDecode(snapshot.data)['login']
                      //         .split(RegExp(r'@'))[0];

                      //     // _password = jsonDecode(snapshot.data)["password"];
                      //   }
                      // }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: FutureBuilder(
                                future: _getUserLoginDetails(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    var login = Map<String, dynamic>.from(
                                        snapshot.data);

                                    var user = login["user"];

                                    if (user == null) {
                                      return Center(
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: AssetImage(
                                              'assets/images/kseb_emblem.jpeg'),
                                        ),
                                      );
                                    }

                                    var dp = user['photo_image'];

                                    var username = user["name"];

                                    Uint8List bytes = base64.decode(dp);

                                    empCodeInitialValue =
                                        user["employee_code"].toString();

                                    print(empCodeInitialValue);

                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 100,
                                            backgroundImage: MemoryImage(bytes),
                                          ),
                                          SizedBox(height: 16),
                                          Text('Welcome Back '),
                                          Text(
                                            '$username ',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 32),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.grey),
                                                ),
                                                onPressed: () {
                                                  // Handle biometric login
                                                },
                                                child: Text(
                                                    'Login with Biometric'),
                                              ),
                                              SizedBox(width: 30),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.grey),
                                                ),
                                                onPressed: () {
                                                  // Handle login with pin
                                                },
                                                child: Text('Login with Pin'),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Visibility(
                                    visible: empCodeInitialValue != '',
                                    child: Text(
                                      empCodeInitialValue,
                                      style: TextStyle(
                                          fontSize: 25,
                                          color:
                                              AppTheme.grey.withOpacity(0.7)),
                                    )),
                                SizedBox(height: 8.0),
                                TextFormField(
                                  // (snapshot.data?.isNotEmpty == true)    ? jsonDecode(snapshot.data)?["password"] ??:'',

                                  initialValue: passwordInitialValue,
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
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
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
                                ),
                                SizedBox(height: 20),
                                Visibility(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isLoggingIn = 0;

                                                  _loginError = '';
                                                });
                                              },
                                              child: Text('Reset Error')),
                                        ],
                                      ),
                                      Text('Login Error $_loginError'),
                                    ],
                                  ),
                                  visible: _isLoggingIn == -1,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 8.0),
                                    RawMaterialButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm'),
                                              content: Text(
                                                  'Are you sure you want to perform this action?'),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.grey),
                                                  ),
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.grey),
                                                  ),
                                                  child: Text('Yes'),
                                                  onPressed: () {
                                                    // Perform the action here
                                                    Navigator.of(context).pop();
                                                    _secureStorage
                                                        .deleteAlllSecureStorageData();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // perform some action
                                      },
                                      child: Text('Another User ?'),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      fillColor:
                                          Color.fromARGB(255, 196, 194, 194),
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    SizedBox(height: 30, width: 40),
                                    Visibility(
                                      visible: _showLoginButton,
                                      child: _isLoggingIn == 1
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.grey),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  MyAPI api = new MyAPI();

                                                  // print("empcode is $_empcode");

                                                  String ext = "@kseberp.in";

                                                  setState(() {
                                                    _isLoggingIn = 1;
                                                  });

                                                  String email =
                                                      "$_empcode$ext";
                                                  String showPhoto = '1';

                                                  _password = "uat123";

                                                  await _setSavedUserNameAndPassword(
                                                      email, _password);

                                                  Map<String, dynamic> result =
                                                      await api.login(email,
                                                          _password, showPhoto);

                                                  // print(result["result_data"]["token"]
                                                  //     ["access_token"]);

                                                  if (result["result_data"] ==
                                                      null) {}

                                                  await _secureStorage
                                                      .writeKeyValuePairToSecureStorage(
                                                          "access_token",
                                                          result["result_data"]
                                                                  ["token"]
                                                              ["access_token"]);

                                                  await _secureStorage
                                                      .writeKeyValuePairToSecureStorage(
                                                          'loginDetails',
                                                          jsonEncode(result[
                                                              'result_data']));

                                                  setState(() {
                                                    _isLoggingIn = 0;
                                                  });

                                                  // print(result["result_data"]);
                                                  // dynamic re = await _secureStorage
                                                  //     .getSecureAllStorageDataByKey('loginDetails');

                                                  // print(re.toString());

                                                  // showAlert(context);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NavigationHomeScreen()),
                                                  );
                                                } on Exception catch (e) {
                                                  print('exception hit');
                                                  print(e);
                                                  setState(() {
                                                    _isLoggingIn = -1;
                                                  });

                                                  _loginError = e.toString();

                                                  Future.delayed(
                                                      Duration(seconds: 3), () {
                                                    _loginError =
                                                        'Restarting App';
                                                    // code to be executed after 2 seconds
                                                  });

                                                  Future.delayed(
                                                      Duration(seconds: 3), () {
                                                    // setState(() {
                                                    //   _isLoggingIn = 0;
                                                    // });

                                                    WidgetsBinding.instance
                                                        .reassembleApplication();

                                                    // code to be executed after 2 seconds
                                                  });

                                                  // print(e);

                                                  // return Future(computation)
                                                  // TODO
                                                }
                                              },
                                              child: Text('Login'),
                                            ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                CheckboxListTile(
                                  value: _rememberMe,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _rememberMe = newValue ??= true;
                                    });
                                  },
                                  title: Text('Remember me'),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }), //
            ),
          ),
        ),
      );
    }
  }

  showUserNameForm1() {
    print(_usernameController.text.length);
    _showFirstTimePasswordFeild =
        _usernameController.text.length == 7 ? true : false;

    print(_usernameController.text.length);

    return Column(
      children: [
        TextField(
            autofocus: true,
            // onChanged: (value) {
            //   setState(() {
            //     _isValidUsername = RegExp(r'^\d{8}$').hasMatch(value);
            //   });
            // },
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(RegExp('[,.]')),
            ],
            maxLength: 7,
            controller: _usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelText: 'User Name',
              prefixIcon: Icon(Icons.person),
              suffixIcon: _usernameController.text.length == 7
                  ? Icon(Icons.check, color: Colors.green)
                  : Icon(Icons.warning, color: Colors.red),
              hintText: 'Enter your user name',
              // errorText: isValidUsername ? null : 'Invalid input',
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.red),
              ),
            )),
        SizedBox(
          width: 20,
          height: 20,
        ),
        _showFirstTimePasswordField
            ? CircularProgressIndicator()
            : TextField(
                decoration: InputDecoration(
                  labelText: 'Password ..',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              )
      ],
    );
  }

  TextFormField showUserNameForm() {
    return TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (text) {
          if (text.length != 8) {
            setState(() {
              _empCodeValidator = false;
            });
          } else {
            setState(() {
              _empCodeValidator = true;
            });
          }

          _empcode = text;

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
          suffixIcon: _usernameController.text.length == 8
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.warning, color: Colors.red),
        ),
        validator: (value) {
          value ??= '';
          if (value.isEmpty) {
            return 'Please enter your empcode';
          }
          return null;
        });
  }

  Widget createLoadingSpinner() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey,
        strokeWidth: 5.0,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
  final Dio _dio = Dio();
  final String _url = "http://erpuat.kseb.in/api/login";

  Future<Map<String, dynamic>> login(
      String email, String password, String showPhoto) async {
    final Map<String, String> data = {
      "email": email,
      "password": password,
      "show_photo": showPhoto
    };

    try {
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
