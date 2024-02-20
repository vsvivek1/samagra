// import 'dart:html';

// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:samagra/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:samagra/app_theme.dart';
import 'package:samagra/extras/nasa_image_of_day.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/navigation_home_screen.dart';
import 'package:samagra/screens/authentication_bottom_sheet.dart';
import 'package:samagra/screens/generate_random_string.dart';
import 'package:samagra/screens/get_oidc_access_token.dart';
import 'package:samagra/screens/get_user_info.dart';
import 'package:samagra/screens/launch_sso_url.dart';
import 'package:samagra/screens/uat_test_display_widget.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:convert';

import '../internet_connectivity.dart';
import 'package:samagra/environmental_config.dart';

// import 'package:samagra/secure_storage/common_functions.dart';
String addPaddingToBase64UrlEncodedString(String base64String) {
  // Add padding to the base64 URL-safe encoded string
  int missingPadding = base64String.length % 4;
  if (missingPadding != 0) {
    base64String += '=' * (4 - missingPadding);
  }
  return base64String;
}

String codeVerifier = generateRandomString();
// String codeChallenge =
//     addPaddingToBase64UrlEncodedString(generateCodeChallenge(codeVerifier));

String codeChallenge = 'MWlv47S554VAgCBkUNgxWacyRGG0Gg1TkTAShA_okW8';

late EnvironmentConfig config;
String DEPLOYEMENT_MODE = '';

class LoginScreen extends StatefulWidget {
  LoginScreen();

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

  bool _ssoLoginLoading = false;

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

  bool _BtnAndPassForSmagraDirect = false;

  bool _showBiometricLoginButtton = false;

  bool externalLinkActivated = false;

  // get _showFirstTimePasswordField => _showFirstTimePasswordFeild;
  //  bool _showFirstTimePasswordField;

  Future<void> loadConfig() async {
    // Initialize environment configuration
    config = await EnvironmentConfig.fromEnvFile();

    // After configuration is loaded, setState to rebuild the widget
    if (mounted) {
      setState(() {
        DEPLOYEMENT_MODE = config.deploymentMode;

        // debugger(when: true);
        _BtnAndPassForSmagraDirect = !(DEPLOYEMENT_MODE.contains('SSO'));
      });
    }
  }

  @override
  void initState() {
    loadConfig();
    // config = EnvironmentConfig.fromEnvFile();

    initUniLinks(); //moved to sso login screen

    super.initState();
  }

  Future<Object> _getUserLoginDetails() async {
    var loginDetails1 =
        await _secureStorage.getSecureAllStorageDataByKey('loginDetails');

// storedLogin

    var slogin =
        await _secureStorage.getSecureAllStorageDataByKey('storedLogin');

    if (!loginDetails1?.isEmpty && loginDetails1["loginDetails"] != null) {
      var ob1 = json.decode(loginDetails1["loginDetails"] ?? '');
      var ob;

      if (ob1 is String) {
        ob = jsonDecode(ob1);
      } else {
        ob = ob1;
      }

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

  setLoginState() {
    _ssoLoginLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    InternetConnectivity.showInternetConnectivityToast(context);

    if (_isLoggingIn == -2 || _ssoLoginLoading || externalLinkActivated) {
      return createLoadingSpinner();
    } else {
      return ScaffoldMessenger(
        child: Scaffold(
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
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!(snapshot.hasData) ||
                              snapshot.data == '' ||
                              snapshot.data['seat_details'] == -1) {
                            // no stored data or stored data is null or seat details -1
                            /// show fist time login screen

                            return Column(
                              children: [
                                if (config.deploymentMode.contains("UAT"))
                                  noStoredLoginDetailsSoFirstLoginScreen(),
                              ],
                            );
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

                                          // String json=

                                          if (snapshot.data['storedLogin'] !=
                                              null) {
                                            var storedLogin =
                                                snapshot.data['storedLogin'] !=
                                                        null
                                                    ? json.decode(snapshot
                                                        .data['storedLogin'])
                                                    : '';

                                            var storedPassword =
                                                (storedLogin != "")
                                                    ? storedLogin['password']
                                                    : '';
                                            _password = storedPassword;
                                          }

                                          passwordInitialValue = _password;

                                          var dp = user['photo_image'] ?? '';

                                          var username = user["name"];

                                          _empcode =
                                              user["employee_code"].toString();

                                          Uint8List bytes = base64.decode(dp);

                                          // debun    sgger(when: true);

                                          empCodeInitialValue =
                                              user["employee_code"].toString();

                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (config.deploymentMode
                                                    .contains("UAT"))
                                                  UATTestWidget(
                                                      isUATTest: true),
                                                ksebMainEmblemAndName(),
                                                Visibility(
                                                  visible: bytes.isEmpty,
                                                  child: RandomAvatar(
                                                      'saytoonz',
                                                      trBackground: true,
                                                      height: 100,
                                                      width: 100),
                                                  //
                                                  // CircleAvatar(
                                                  //     radius: 30,
                                                  //     backgroundImage: AssetImage(
                                                  //         'assets/images/kseb_emblem.jpeg'),
                                                  //   ),
                                                ),
                                                Visibility(
                                                  visible: bytes.isNotEmpty,
                                                  child: CircleAvatar(
                                                    radius: 100,
                                                    backgroundImage:
                                                        MemoryImage(bytes),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Welcome Back ',
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ),
                                                Text(
                                                  '$username ',
                                                  style: TextStyle(
                                                      color: ksebColor,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                // SizedBox(height: 32),
                                                SizedBox(height: 16),
                                                displayStoredEmployeeCode(),

                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Spacer(),
                                                    if (_showBiometricLoginButtton) ...[
                                                      biometricLoginButton(
                                                          context),
                                                      Spacer(),
                                                    ],
                                                    if (DEPLOYEMENT_MODE
                                                        .contains('SSO')) ...[
                                                      Center(
                                                          child: ssoLoginButton(
                                                              context)),
                                                      Spacer(),
                                                      changeUserButton(context),
                                                      Spacer(),
                                                    ]
                                                  ],
                                                ),
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
                                      SizedBox(height: 8.0),
                                      if (_BtnAndPassForSmagraDirect)
                                        passWordForSamagraDirect(),
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
                                          // SizedBox(height: 30, width: 40),
                                          if (_BtnAndPassForSmagraDirect)
                                            loginButtonForSamagraDirect(
                                                context),
                                        ],
                                      ),
                                      // SizedBox(height: 1.0)

                                      CheckboxListTile(
                                        activeColor: Colors.green[10],
                                        value: _rememberMe,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _rememberMe = newValue ??= true;
                                          });
                                        },
                                        title: Text('Remember me'),
                                      ),

                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .5,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        // child: NasaImageOfTheDay()
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
        ),
      );
    }
  }

  RawMaterialButton changeUserButton(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm'),
              content: Text('Are you sure you want to perform this action?'),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(ksebColor),
                  ),
                  child: Text('Yes'),
                  onPressed: () {
                    // Perform the action here
                    Navigator.of(context).pop();

                    _secureStorage.deleteAlllSecureStorageData();

                    setState(() {});
                  },
                ),
              ],
            );
          },
        );

        // perform some action
      },
      child: Text(
        'Another User ?',
        style: TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      fillColor: ksebColor

      // Color.fromARGB(
      //     255, 196, 194, 194)

      ,
      padding: EdgeInsets.all(10.0),
    );
  }

  ElevatedButton ssoLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(ksebColor),
      ),
      onPressed: () =>
          {loginUsingSso(context, _ssoLoginLoading, setLoginState, _empcode)},
      child:
          Text(style: TextStyle(color: Colors.orangeAccent), 'Login with SSO'),
    );
  }

  Column ksebMainEmblemAndName() {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: Image(image: AssetImage('assets/images/kseb.jpg')),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // clipBehavior: Clip.hardEdge,
            color: Color.alphaBlend(
                Colors.white70, Color.fromARGB(255, 197, 203, 219)),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(20),
            child: Text('KERALA STATE ELECTRICTY BOARD LIMITED',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: Color.fromARGB(255, 16, 87, 161))),
          ),
        ),
      ],
    );
  }

  ElevatedButton biometricLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(ksebColor),
      ),
      onPressed: () {
        _handleBiometricLogin(context);
        // Handle biometric login
      },
      child: Text('Login with Biometric'),
    );
  }

  Visibility loginButtonForSamagraDirect(BuildContext context) {
    return Visibility(
      // visible: _showLoginButton,
      visible: true,
      child: _isLoggingIn == 1
          ? CircularProgressIndicator()
          : Container(
              width: MediaQuery.sizeOf(context).width * .8,
              child: Row(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(ksebColor),
                    ),
                    onPressed: () async {
                      await proceedForLogin(context, 'regular');
                    },
                    child: Text('Login $DEPLOYEMENT_MODE'),
                  ),
                  Spacer(),
                  changeUserButton(context)
                ],
              ),
            ),
    );
  }

  Visibility displayStoredEmployeeCode() {
    return Visibility(
        visible: empCodeInitialValue != '',
        child: Text(
          empCodeInitialValue,
          style: TextStyle(fontSize: 25, color: AppTheme.grey.withOpacity(0.7)),
        ));
  }

  TextFormField passWordForSamagraDirect() {
    return TextFormField(
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
            borderSide: BorderSide(color: Colors.red),
          ),
          suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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
    );
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

      var result =
          await api.login(email, _password, showPhoto, context).catchError((e) {
        throw e;
      });

      if (result == -1 || result['result_flag'] == -1) {
        return handleServerLoginScafoldMessenger(context, occation);
      }

      // if (result["result_data"] == null) {}

      await _handlServerLogin(result, occation, context);
    } catch (e) {
      _handleServerLoginError(context, e, occation);
    }
  }

  void _handleServerLoginError(BuildContext context, Object e, occation) {
    String msg =
        'Error in connectecing With Server. Please Report or try after Some time';
    ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        content: Text(
          msg,
          style: TextStyle(
              color: Color.alphaBlend(
                  Color.fromARGB(255, 235, 79, 58), ksebColor)),
        ),
        duration: Duration(seconds: 15))));
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
  }

  Future<void> _handlServerLogin(result, occation, BuildContext context,
      {oIdAccessTokens}) async {
    String errorMsg = 'SERVER ERROR';

    if (!(result is Map) &&
        result.response == null &&
        result.response.statusCode != 200) {
      if (result.error != null) {
        errorMsg = result.error;
      }

      if (result.resoponse != null) {
        var data = result.response.data;

        if (data.containsKey('error')) {
          errorMsg = result.response.data['error'];
        } else if (data.containsKey('wsDisplayMessage')) {
          errorMsg = result.response.data['wsDisplayMessage'];
          // debugger(when: true);
        }
      }

      // debugger(when: true);

      Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.black,
        textColor: const Color.fromARGB(255, 244, 3, 3),
        fontSize: 16.0,
      );

      setState(() {
        _ssoLoginLoading = false;
        externalLinkActivated = false;
      });
      print(result.response);
      showErrorMessage(
          'Error fetching data. Status code: ${result.response.data['error']}',
          context);

      return;
    }

    var resultData = {};
    if (occation == 'sso') {
      if (!(result is Map) && result.error != null) {
        return;
      }
      resultData = jsonDecode(result["result_data"]);

      print(" access token ${oIdAccessTokens[0]} - accees token end");

      // gmailMe(oIdAccessTokens[0]);

      await _secureStorage.writeKeyValuePairToSecureStorage(
          "access_token", oIdAccessTokens[0]);

      await _secureStorage.writeKeyValuePairToSecureStorage(
          "refresh_token", oIdAccessTokens[1]);
    } else {
      resultData = result["result_data"];

      await _secureStorage.writeKeyValuePairToSecureStorage(
          "access_token", resultData["token"]["access_token"]);
    }

    // debugger(when: true);

    await _secureStorage.writeKeyValuePairToSecureStorage(
        'loginDetails', jsonEncode(resultData));

    if (occation == 'regular') {
      setState(() {
        _ssoLoginLoading = false;
        _isLoggingIn = 0;
      });
    } else {
      setState(() {
        _ssoLoginLoading = false;
        _firstTimeLoginSpinner = 1;
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
    );
  }

  Future<void> handleServerLoginScafoldMessenger(
      BuildContext context, occation) {
    ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        content: Text('Invalid Credentials'), duration: Duration(seconds: 5))));

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
        // firstTimeLoginPassword(),
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
              loginUsingSso(context, _ssoLoginLoading, setLoginState, _empcode);

              //
              // await proceedForLogin(context, 'firstTime');
            },
            child: Text('Login'),
          ),
        ),
      ],
    );
  }

  Visibility firstTimeLoginPassword() {
    return Visibility(
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
      child: SpinKitFadingCube(color: ksebColor),
      // child: CircularProgressIndicator(
      //   backgroundColor: Colors.grey,
      //   strokeWidth: 5.0,
      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      // ),
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

  loginUsingSso(context, _ssoLoginLoading, setLoginState, empcode) {
    initUniLinks();
    setLoginState();

    launchSSOUrl(codeVerifier, codeChallenge, empcode);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SSOLogin()),
    // );
  }

  void initUniLinks() async {
    // Handle the initial URL when the app is opened with a URL
    try {
      final initialLink = await getInitialLink();

      if (initialLink == null) {
        return;

        /// added because initla null lik causing error
      }

      late StreamSubscription _sub;

      print('$initialLink initial link');

      _sub = linkStream.listen((String? link) async {
        if (link == '') {
          return;
        }
        // print("link $link");
        setState(() {
          externalLinkActivated = true;
        });

        String token = extractTokenFromLink(link!);

        if (token != '') {
          // print(token);

          List<String> oIdAccessTokens =
              await getOidcAccessTokens(codeVerifier, token);

          // debugger(when: true);

          try {
            var result =
                await getUserInfo(oIdAccessTokens[0], _ssoLoginLoading);

            // debugger(when: true);

            setState(() {
              externalLinkActivated = false;
            });

            // debugger(when: true);
            String occation = 'sso';

            await _handlServerLogin(result, occation, context,
                oIdAccessTokens: oIdAccessTokens);

//1049878 chalode ae

            /// 1063736
            // debugger(when: true);

            // print(result);
          } on Exception catch (e) {
            String occation = 'regular';

            debugger(when: true);
            _handleServerLoginError(context, e, occation);
            print(e);
            // TODO
          } finally {
            print('OidcAccessTokenxyx ');
          }
        }
        // print(_sub);
        // Parse the link and warn the user, if it is not correct
      }, onError: (err) {
        // Handle exception by warning the user their action did not succeed
      });

      // debugger(when: true);

      // Process the initial URL accordingly
    } on PlatformException {
      // Handle exception if unable to get initial URL
    }
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

  void showErrorMessage(String s, context) {
    print(s);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(s),
    //     duration: Duration(seconds: 5), // Optional duration
    //   ),
    // );
  }
}

String extractTokenFromLink(String inputString) {
  List<String> splitList = inputString.split('code=');

  if (splitList.length > 1) {
    String secondItem = splitList[1]
        .split(' ')[0]; // Assuming the second item is separated by a space
    return secondItem;
  } else {
    return '';
  }
}

class MyAPI {
  final Dio _dio = Dio();
  final String _url = "${config.liveServiceUrl}login";

  Future login(String email, String password, String showPhoto, context) async {
    final Map<String, String> data = {
      "email": email,
      "password": password,
      "show_photo": showPhoto
    };

    try {
      print(_url);
      Response response = await _dio.post(_url, data: data);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            content: Text('Too many requests and Load /server busy'),
            duration: Duration(seconds: 3))));

        var result;

        return Future(() => result);
      }

      if (response.statusCode != 200 || response.data['result_flag'] == -1) {
        // String resultMessage = response['result_message'];

        // String resultMessage = response.result_message;

        // ScaffoldMessenger.of(context).showSnackBar((SnackBar(
        //     content: Text("$resultMessage"), duration: Duration(seconds: 3))));

        return -1;
      }
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e);
      } else {
        // print(e.request);
      }
      throw e;
    }
  }
}
