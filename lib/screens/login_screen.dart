import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/userAuthentication.dart';

import '../app_theme.dart';

import '../screens/home_screen.dart';

class LoginScreenState extends State<LoginScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  final formKey = GlobalKey<FormState>();
  String formType = "login"; 

  bool _loading;
  bool _show;

  TextEditingController _usernameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;

  void initState() {
     _loading = true;
     _show = false;
     _usernameController = TextEditingController();
     _emailController = TextEditingController();
     _passwordController = TextEditingController();
    print("I am in login screen");
    super.initState();
  }

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  void _writeToken(String token) async {
    final tokenPayload = token.split(".");
    final payloadMap = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(tokenPayload[1]))));
    //print(payloadMap);
    _sharedPreferences = await _prefs;
    _sharedPreferences.setString('token', token);
    _sharedPreferences.setString("userId", payloadMap["user_id"].toString());
    _sharedPreferences.setString("email", payloadMap["email"].toString());
  }

  void moveToRegister() {
    //formKey.currentState.reset();

    setState(() {
      formType = "register";
    });
  }

  void moveToLogin() {
    //formKey.currentState.reset();

    setState(() {
      formType = "login";
    });
  }

  //Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff191654),
                  Color(0xff43c6ac),
                  // Color(0xff6dffe1),
                ]),
          ),
        ),
        title: Text("Flutter Blog App"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(25.0),
          child: Form(
            key: formKey,
            autovalidate: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: createInputs() + createButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> createInputs() {
    return [
      logo(),
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value.isEmpty)
            return 'Email required';
          else {
            Pattern pattern = r"[A-Za-z0-9]*@[A-Za-z]+.[a-zA-Z]{2,}";
            RegExp regex = RegExp(pattern);
            if (!regex.hasMatch(value))
              return 'Enter valid Email';
            else
              return null;
          }
          return null;
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            var err = null;
            if (value.isEmpty) err = 'Password required';
            // else if(value.length<8) err='Password length should not be less than 8';
            return err;
          },
        ),
      ),
    ];
  }

  List<Widget> createButtons() {
    if (formType == "login") {
      return [
        RaisedButton(
          child: Text("Login", style: TextStyle(fontSize: 20.0)),
          textColor: Colors.white,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            setState(() {
              _loading = true;
              _show = true;
            });
            final form = formKey.currentState;
            if (form.validate()) {
              var email = _emailController.text;
              var password = _passwordController.text;
              String token;
              await Provider.of<Authentication>(context)
                  .attemptLogin(email, password).then((data){
                    setState(() {
                      _loading = false;
                      token = data;
                    });
                  });
              if (token != null) {
                _writeToken(token);
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              } else {
                displayDialog(context, "Incorrect email or password",
                    "No account was found matching that email and password");
              }
            }
          },
        ),
        FlatButton(
          child: Text("Dont have an account? Create Account?",
              style: TextStyle(fontSize: 14.0)),
          textColor: Colors.indigo,
          onPressed: moveToRegister,
        ),
        (_show==true && _loading==true)?
          JumpingDotsProgressIndicator(fontSize: 60.0,):Text(""),
      ];
    } else {
      return [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
          validator: (value) {
            return value.isEmpty ? 'Username required' : null;
          },
        ),
        Container(

          child :
           RaisedButton(
          child: Text("Create account", style: TextStyle(fontSize: 20.0)),
          textColor: Colors.white,
          //color : Colors.teal[700],
          color: Theme.of(context).colorScheme.primary,
          //color: Colors.transparent,
          onPressed: () async {
            setState(() {
              _loading = true;
              _show = true;
            });
            if (formKey.currentState.validate()) {
              var email = _emailController.text;
              var password = _passwordController.text;
              var username = _usernameController.text;
              List response;
              await Provider.of<Authentication>(context)
                  .attemptSignUp(email, password, username).then((data){
                    setState(() {
                      _loading = false;
                      print(data);
                      response = data;
                    });
                  });
              String token = response[0];
              if(token!=null){
                _writeToken(token);
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              }else{
                String error = response[1];
                displayDialog(context, "Error", error);
              }
            }
          },
        )),
        FlatButton(
          child:
              Text("Have an account? Login", style: TextStyle(fontSize: 14.0)),
          textColor: Colors.indigo,
          onPressed: moveToLogin,
        ),
        _show==true && _loading==true?
          JumpingDotsProgressIndicator(fontSize: 60.0,):Text(""),
      ];
    }
  }

  Widget logo() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: CircleAvatar(
        radius: 110.0,
        backgroundColor: Colors.transparent,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  static const routeName = "/login-screen";
  @override
  LoginScreenState createState() => LoginScreenState();
}