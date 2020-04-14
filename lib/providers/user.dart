import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../server_util.dart' as Serverr;

class User with ChangeNotifier {
  static const baseUrl = Serverr.SERVER_IP + "/api/v1/";
  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  final int user_id;
  final String email;
  String username;
  String about;
  String profile_image_url;
  bool is_following;
  int followerCount;
  int followingCount;

  User({
    @required this.user_id,
    @required this.username,
    @required this.profile_image_url,
    this.email,
    this.about,
    this.is_following,
    this.followerCount,
    this.followingCount,
  });

  Future<void> followUser(String userId) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    print("lalalal"+token);
    String url = baseUrl + "followers/" + userId;
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      is_following = true;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> unfollowUser(String userId) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    print("lalalal"+token);
    String url = baseUrl + "followers/" + userId;
    try {
      final response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      is_following = false;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void followUnfollow() {
    is_following = !is_following;
    notifyListeners();
  }
}
