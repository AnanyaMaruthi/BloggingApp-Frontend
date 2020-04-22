import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../server_util.dart' as Server;

class Opinion with ChangeNotifier {
  final String opinion_id;
  final String article_id;
  final String username;
  final String user_id;
  final String content;
  final DateTime opinion_date;
  final String user_profile_image_path;

  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  
  Opinion({
    @required this.opinion_id,
    @required this.article_id,
    @required this.username,
    @required this.user_id,
    @required this.content,
    @required this.opinion_date,
    @required this.user_profile_image_path,
  });

  Future<void> deleteOpinion(String opinionId , String articleId) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "articles/" + articleId + "/opinions/" + opinionId;
    try {
      final response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("Delete successful");
      } else {
        print("Delete unsuccessful");
      }
    } catch (error) {
      throw error;
    }
  }
}
