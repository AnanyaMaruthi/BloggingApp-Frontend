import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // static Color _iconColor = Colors.redAccent.shade200;

  // static const Color _lightPrimaryColor = Colors.white;
  // static const Color _lightPrimaryVariantColor = Color(0XFFE1E1E1);
  // static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xfff3f7f6),
    primaryColor: Colors.teal,
    accentColor: Colors.white60,
    // primarySwatch: Colors.purple,
    // appBarTheme: AppBarTheme(

    //   color: _lightPrimaryVariantColor,
    //   iconTheme: IconThemeData(color: _lightOnPrimaryColor),
    // ),
    // colorScheme: ColorScheme.light(
    //   primary: _lightPrimaryColor,
    //   primaryVariant: _lightPrimaryVariantColor,
    //   secondary: _lightSecondaryColor,
    //   onPrimary: _lightOnPrimaryColor,
    // ),
    // iconTheme: IconThemeData(
    //   color: _iconColor,
    // ),
    // textTheme: _lightTextTheme,
  );

  static final TextTheme _lightTextTheme = TextTheme(
    headline: _lightScreenHeadingStyle,
    body1: _lightScreenTaskNameStyle,
    body2: _lightScreenTaskDurationStyle,
  );

  static final TextStyle _lightScreenHeadingStyle = TextStyle(
      fontSize: 48.0, letterSpacing: 1.2, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskNameStyle =
      TextStyle(fontSize: 20.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskDurationStyle =
      TextStyle(fontSize: 16.0, color: Colors.grey);
}