import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './user.dart';

import '../server_util.dart' as Server;

class Users with ChangeNotifier {
  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  List<User> _users = [];

  List<User> get users {
    return [..._users];
  }

  Future<User> getProfile() async {
    String url = baseUrl + "user";
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    print("lalalal"+token);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final data = responseJson["user"];
        User user = User(
          user_id: data["user_id"],
          username: data["username"],
          email: data["email"],
          about: data["about"],
          profile_image_url: data["profile_image_url"],
          followerCount: data["followercount"],
          followingCount: data["followingcount"],
        );
        print("Fetched user profile");
        return user;
      } else {
        print(response.body);
        throw "Failed to load Profile";
      }
    } catch (error) {
      print(error);
      throw "Failed to load Profile";
    }
  }

  // Change password
  Future<String> changePassword(String oldPassword, String newPassword) async {
    String url = baseUrl + "user/password";
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    try {
      var response = await http.patch(
        url,
        body: {"oldPassword": oldPassword, "newPassword": newPassword},
        headers: {HttpHeaders.authorizationHeader: token},
      );
      final responseJson = json.decode(response.body);
      if (responseJson["error"] == false) {
        return "Changed password successfully";
      } else {
        throw responseJson["message"];
      }
    } catch (error) {
      throw error;
    }
  }

  Future<User> fetchUserById(String userId) async {
    print("what is the about error");
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "users/" + userId;
    print("check" + url);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        print(responseJson);
        final userData = responseJson["user"];
        User user = User(
          username: userData["username"],
          user_id: userData["user_id"],
          email: userData["email"],
          about: userData["about"],
          profile_image_url: userData["profile_image_url"],
          followerCount: userData["followercount"],
          followingCount: userData["followingcount"],
          is_following: userData["is_following"] == 0 ? false : true,
        );
        return user;
      } else if (response.statusCode == 404) {
        throw "User not found";
      } else {
        throw "Failed to load user";
      }
    } catch (error) {
      print(error);
      throw "error";
    }
  }

// Update user profile
  Future<String> updateProfile(Map<String, dynamic> data, File image) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "user";
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      print(filename);
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["username"] = data["username"];
    request.fields["about"] = data["about"];
    request.fields["profile_image_url"] = data["imageUrl"];
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      print(response);
      final responseJson = json.decode(response);

      if (responseJson["error"] == false) {
        return "Successfully updated profile";
      } else {
        print(responseJson["message"]);
        throw "Failed to update profile";
      }
    } catch (error) {
      print(error);
      throw "Failed to update profile";
    }
  }

  Future<void> searchUsers(String query) async {
    List<User> fetchedUsers = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "users?q=" + query;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final user in responseJson['users']) {
          fetchedUsers.add(User(
            user_id: user["user_id"],
            email: user["email"],
            username: user["username"],
            profile_image_url: user["profile_image_url"],
            is_following: user["is_following"] == 0 ? false : true,
          ));
        }
        _users = [...fetchedUsers];
      } else {
        print(response.body);
        throw "Failed to load users";
      }
    } catch (error) {
      print(error);
      throw "Failed to load users";
    }
  }
}
