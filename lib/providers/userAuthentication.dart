import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../server_util.dart' as Server;

class Authentication with ChangeNotifier {
  static const SERVER_IP = Server.SERVER_IP;
  final storage = FlutterSecureStorage();

  String _username, _email, _profile_image_url;

  String get username {
    return _username;
  }

  String get email {
    return _email;
  }

  String get profileImageUrl {
    return _profile_image_url;
  }

  Future<List> attemptSignUp(
      String email, String password, String username) async {
    List<String> status = [];
    try {
      var response = await http.post(
        "$SERVER_IP/api/v1/signup",
        body: {
          "email": email,
          "password": password,
          "username": username,
          "about": "",
          "profile_image_url": ""
        },
      );
      final responseJson = json.decode(response.body);
      if(response.statusCode == 200){
        String token = responseJson["token"];
        final tokenPayload = token.split(".");
        final payloadMap = jsonDecode(utf8
            .decode(base64Url.decode(base64Url.normalize(tokenPayload[1]))));
        _username = payloadMap["username"];
        _email = payloadMap["email"];
        _profile_image_url = payloadMap["profile_image_url"];
        print("obtained token" + token);
        status.add(token);
        status.add(null);
        return status;
      }else{
        print(response.body);
        if(response.statusCode==409){
          status.add(null);
          status.add("Please try to sign up using another username or log in if you already have an account.");
        }
        else if(response.statusCode==400){
          status.add(null);
          status.add("Required information is incomplete");
        }
        else{
          status.add(null);
          status.add("Unknown error");
        }
        return status;
      }
    } catch (error) {
      throw error;
    }
  }

  Future<String> attemptLogin(String email, String password) async {
    try {
      var response = await http.post(
        "$SERVER_IP/api/v1/login",
        body: {"email": email, "password": password},
      );
      final responseJson = json.decode(response.body);
      print(responseJson);
      print(response.statusCode);
      if (response.statusCode == 200) {
        String token = responseJson["token"];
        final tokenPayload = token.split(".");
        final payloadMap = jsonDecode(utf8
            .decode(base64Url.decode(base64Url.normalize(tokenPayload[1]))));
        _username = payloadMap["username"];
        _email = payloadMap["email"];
        _profile_image_url = payloadMap["profile_image_url"];
        print("obtained token" + token);
        return token;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }
}