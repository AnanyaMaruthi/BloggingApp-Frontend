import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

//import '../app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "/splash-screen";
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  void initState() {
    print("i am in splash screen");
    _fetchSessionAndNavigate();
    super.initState();
  }

  _fetchSessionAndNavigate() async {
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    if (token != null) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
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
      backgroundColor: Color(0xfff3f7f6),
      body: Container(
        margin: const EdgeInsets.only(top: 100.0),
        child: logo(),
      ),
    );
  }
}
