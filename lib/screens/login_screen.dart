// import 'dart:html';

// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:samagra/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:samagra/app_theme.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/authentication_bottom_sheet.dart';
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

  final SecureStorage _secureStorage = SecureStorage();
  String _empcode = '', _password = '';
  bool _obscureText = true;

  bool _showLoginButton = false;
  bool _rememberMe = true;
  int _isLoggingIn = 0;
  String _loginError = ' ';
  var _isValidUsername;

  int _firstTimeLoginSpinner =
      -1; //-1 init state, 0 spinning, 1 spin stop and load new //-2 error

  bool _showpassWordSpinner = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _firstTimeUserNameController = TextEditingController();
  TextEditingController _firstTimePassWordController = TextEditingController();

  var username;

  // String access_token;

  bool _empCodeValidator = false;
  String empCodeInitialValue = '';
  String passwordInitialValue = '';

  bool _showFirstTimePasswordFeild = false;

  bool _showFirstTimePasswordField = false;

  bool _showFirstTimeSubmitKeyboard = false;

  // get _showFirstTimePasswordField => _showFirstTimePasswordFeild;
  //  bool _showFirstTimePasswordField;

  @override
  void initState() {
    super.initState();
  }

  Future<Object> _getUserLoginDetails() async {
    var loginDetails1 =
        await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

// storedLogin

    var slogin =
        await _secureStorage.getSecureAllStorageDataByKey('storedLogin');

    if (!loginDetails1?.isEmpty && loginDetails1["loginDetails"] != null) {
      var ob = json.decode(loginDetails1["loginDetails"] ?? '');

      ob['storedLogin'] = slogin['storedLogin'];

      // ob["seat_details"] =
      //     this.getCurrentSeatDetails(_loginDetails1["loginDetails"]);

      return Future.value(ob);
    } else {
      var ob = {};

      ob["seat_details"] = -1;

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

    if (_isLoggingIn == -2) {
      return createLoadingSpinner();
    } else {
      return Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: 1000,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: FutureBuilder(
                      // future: _getSavedUsernameAndPassword(),
                      future: _getUserLoginDetails(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!(snapshot.hasData) ||
                            snapshot.data == '' ||
                            snapshot.data['seat_details'] == -1) {
                          print('no stored login details');
                          // no stored data or stored data is null or seat details -1
                          /// show fist time login screen
                          return noStoredLoginDetailsSoFirstLoginScreen();
                        } else {
                          try {
                            var loginDetails;
                            if (snapshot.data.runtimeType == 'String') {
                              loginDetails = json.decode(snapshot.data);
                            } else {
                              loginDetails = snapshot.data;
                            }

                            passwordInitialValue =
                                loginDetails!['password'] ?? '';
                          } on Exception catch (e) {
                            return Text('An error occurred @190: $e');
                          }

                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 100),
                                child: FutureBuilder(
                                    future: _getUserLoginDetails(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        var login = Map<String, dynamic>.from(
                                            snapshot.data);

                                        var user = login["user"];

                                        // print(snapshot
                                        //     .data['storedLogin'].runtimeType);
                                        var storedLogin = json.decode(
                                            snapshot.data['storedLogin']);

                                        var storedPassword =
                                            storedLogin['password'];

                                        _password = storedPassword;

                                        passwordInitialValue = _password;

                                        var dp = user['photo_image'] ?? '';

                                        var username = user["name"];

                                        _empcode =
                                            user["employee_code"].toString();

                                        Uint8List bytes = base64.decode(dp);

                                        empCodeInitialValue =
                                            user["employee_code"].toString();

                                        // print(empCodeInitialValue);

                                        // return Text('text');

                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 125,
                                                child: Image(
                                                    image: AssetImage(
                                                        'assets/images/kseb.jpg')),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(20),
                                                child: Text(
                                                    'KERALA STATE ELECTRICTY BOARD LIMITED',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 14,
                                                        color: Color.fromARGB(
                                                            255, 16, 87, 161))),
                                              ),
                                              CircleAvatar(
                                                radius: 100,
                                                backgroundImage:
                                                    MemoryImage(bytes),
                                              ),
                                              SizedBox(height: 16),
                                              Text('Welcome Back '),
                                              Text(
                                                '$username ',
                                                style: TextStyle(
                                                    color: ksebColor,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 32),
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  ksebColor),
                                                    ),
                                                    onPressed: () {
                                                      _handleBiometricLogin(
                                                          context);
                                                      // Handle biometric login
                                                    },
                                                    child: Text(
                                                        'Login with Biometric'),
                                                  ),
                                                  SizedBox(width: 30),
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  ksebColor),
                                                    ),
                                                    onPressed: () {
                                                      // Handle login with pin
                                                    },
                                                    child:
                                                        Text('Login with Pin'),
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
                                              color: AppTheme.grey
                                                  .withOpacity(0.7)),
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
                                          focusedErrorBorder:
                                              OutlineInputBorder(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                                    Colors
                                                                        .grey),
                                                      ),
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    ksebColor),
                                                      ),
                                                      child: Text('Yes'),
                                                      onPressed: () {
                                                        // Perform the action here
                                                        Navigator.of(context)
                                                            .pop();

                                                        _secureStorage
                                                            .deleteAlllSecureStorageData();

                                                        setState(() {});
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
                                          fillColor: ksebColor

                                          // Color.fromARGB(
                                          //     255, 196, 194, 194)

                                          ,
                                          padding: EdgeInsets.all(10.0),
                                        ),
                                        SizedBox(height: 30, width: 40),
                                        Visibility(
                                          // visible: _showLoginButton,
                                          visible: true,
                                          child: _isLoggingIn == 1
                                              ? CircularProgressIndicator()
                                              : ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                ksebColor),
                                                  ),
                                                  onPressed: () async {
                                                    await proceedForLogin(
                                                        context, 'regular');
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
        }),
      );
    }
  }

  Center noStoredLoginDetailsSoFirstLoginScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
        child: Column(children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/kseb_emblem.jpeg'),
          ),
          SizedBox(height: 1, width: 1),
          showUserNameForm1(),
        ]),
      ),
    );
  }

  Future<void> proceedForLogin(BuildContext context, occation) async {
    try {
      MyAPI api = new MyAPI();

      String ext = "@kseberp.in";

      if (occation == 'regular') {
        setState(() {
          _isLoggingIn = 1;
        });
      } else {
        setState(() {
          _empcode = _usernameController.text;
          _password = _firstTimePassWordController.text;
          _firstTimeLoginSpinner = 0;
        });
      }

      String email = "$_empcode$ext";
      String showPhoto = '1';

      _password = "uat123";
      //_password = "pras@205";
      //1049878

      await _setSavedUserNameAndPassword(email, _password);

      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          content: Text('loggining in '), duration: Duration(seconds: 3))));

      // print(
      //     "$email is email and password is $_password from proceed for login function");

      var result =
          await api.login(email, _password, showPhoto, context).catchError((e) {
        throw e;
      });

      // return;

      print('result oflogin request below');

      if (result == -1 || result['result_flag'] == -1) {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            content: Text('Invalid Credentials'),
            duration: Duration(seconds: 5))));

        if (occation == 'regular') {
          setState(() {
            _isLoggingIn = 0;
          });
        } else {
          setState(() {
            _firstTimeLoginSpinner = 1;
          });
        }

        return Future(() => '');
      }

      // print(result["result_data"]["token"]
      //     ["access_token"]);

      if (result["result_data"] == null) {}

      await _secureStorage.writeKeyValuePairToSecureStorage(
          "access_token", result["result_data"]["token"]["access_token"]);

      await _secureStorage.writeKeyValuePairToSecureStorage(
          'loginDetails', jsonEncode(result['result_data']));

      if (occation == 'regular') {
        setState(() {
          _isLoggingIn = 0;
        });
      } else {
        setState(() {
          _firstTimeLoginSpinner = 1;
        });
      }

      // print(result["result_data"]);
      // dynamic re = await _secureStorage
      //     .getSecureAllStorageDataByKey('loginDetails');

      // print(re.toString());

      // showAlert(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          content: Text(e.toString()), duration: Duration(seconds: 5))));
      print('exception hit');
      print(e);

      if (occation == 'regular') {
        setState(() {
          _isLoggingIn = -1;
        });
      } else {}

      _loginError = e.toString();

      Future.delayed(Duration(seconds: 3), () {
        _loginError = 'Restarting App';
        // code to be executed after 2 seconds
      });

      Future.delayed(Duration(seconds: 3), () {
        // setState(() {
        //   _isLoggingIn = 0;
        // });

        WidgetsBinding.instance.reassembleApplication();

        // code to be executed after 2 seconds
      });

      // print(e);

      // return Future(computation)
      // TODO
    }
  }

  showUserNameForm1() {
    return Column(
      children: [
        TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _showpassWordSpinner = _usernameController.text.length > 1 &&
                        _usernameController.text.length < 8
                    ? true
                    : false;

// print(_showpassWordSpinner)
                if (_showpassWordSpinner) {
                  // show the spinning icon for 2 seconds and then show the password field
                  Timer(Duration(seconds: 1), () {
                    setState(() {
                      _empcode = _usernameController.text;
                      _showFirstTimePasswordField =
                          _usernameController.text.length == 7 ? true : false;
                      if (_showFirstTimePasswordField) {
                        _showpassWordSpinner = false;
                      }
                    });
                  });
                }
              });
            },
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
        Visibility(
            visible: _showpassWordSpinner, child: CircularProgressIndicator()),
        Visibility(
          // visible: _showFirstTimePasswordField,
          visible: _showFirstTimePasswordField,
          child: TextField(
            onChanged: (value) {
              setState(() {
                if (_firstTimeUserNameController.text.length > 3) {
                  _showFirstTimeSubmitKeyboard = true;
                }
              });
            },
            controller: _firstTimePassWordController,
            decoration: InputDecoration(
              labelText: 'Password ..',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            obscureText: true,
          ),
        ),
        SizedBox(height: 30, width: 40),
        Visibility(
          // visible: _showFirstTimeSubmitKeyboard,
          visible: true,
          // child: !_showFirstTimeSubmitKeyboard
          child:
              // false
              //     ? CircularProgressIndicator()
              //     : (_firstTimeLoginSpinner == 0)
              //         ? CircularProgressIndicator()
              //         :
              ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            ),
            onPressed: () async {
              await proceedForLogin(context, 'firstTime');
            },
            child: Text('Login'),
          ),
        ),
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

  void _handleBiometricLogin(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Center(child: AuthenticationBottomSheet()),
          );
        });
  }
}

class MyAPI {
  final Dio _dio = Dio();
  final String _url = "http://erpuat.kseb.in/api/login";

  Future login(String email, String password, String showPhoto, context) async {
    final Map<String, String> data = {
      "email": email,
      "password": password,
      "show_photo": showPhoto
    };

    try {
      Response response = await _dio.post(_url, data: data);

      // print(response.statusCode);

      // print('dio response above');

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            content: Text('Too many requests and Load /server busy'),
            duration: Duration(seconds: 3))));

        var result;

        return Future(() => result);
      }

      // print("MESSAGE HERE $response");

      if (response.statusCode != 200 || response.data['result_flag'] == -1) {
        // String resultMessage = response['result_message'];

        // String resultMessage = response.result_message;

        // ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        //     content: Text("$resultMessage"), duration: Duration(seconds: 3))));

        print(response);
        return -1;
      }
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        // print('\n          Thee is some errot in loggin in , response is below $e.response \n');

        print(e.response!.statusCode);
        print(e.response!.data);
        print(e.response!.headers);

        print('error above');
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
