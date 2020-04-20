import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/collection_insert_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

import '../providers/userAuthentication.dart';

class MainDrawer extends StatelessWidget {
  // final storage = FlutterSecureStorage();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  void _deleteToken() async {
    _sharedPreferences = await _prefs;
    _sharedPreferences.remove("token");
    _sharedPreferences.remove("userId");
    _sharedPreferences.remove("email");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xff191654),
                  Color(0xff43c6ac),
                ],
              ),
            ),
            // child: Image.asset('assets/images/logo1.png'),
          ),
          ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              }),
          ListTile(
              leading: Icon(Icons.home),
              title: Text("Home Page"),
              onTap: () {
                Navigator.of(context).pushNamed(HomeScreen.routeName);
              }),
          ListTile(
              leading: Icon(Icons.bookmark),
              title: Text("Bookmarks"),
              onTap: () {
                Navigator.of(context).pushNamed(BookmarkScreen.routeName);
              }),
          ListTile(
              leading: Icon(Icons.collections),
              title: Text(" Add Collections"),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(CollectionInsertScreen.routeName);
              }),
          ListTile(
              leading: Icon(Icons.explore),
              title: Text("Explore"),
              onTap: () {
                Navigator.of(context).pushNamed(ExploreScreen.routeName);
              }),
          Divider(),
          ListTile(
              title: Text("Logout"),
              trailing: Icon(Icons.cancel),
              onTap: () {
                _deleteToken();
                // storage.delete(key: "token");
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login-screen', (Route<dynamic> route) => false);
              }),
        ],
      ),
    );
  }
}
