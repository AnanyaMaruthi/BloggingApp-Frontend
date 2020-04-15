import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../server_util.dart' as Server;
import './opinion.dart';

class Opinions with ChangeNotifier{
  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  List<Opinion> _opinions = [];
  List<Opinion> _replies = [];

  // Get Opinions of an article
  Future<void> getOpinions(String articleId) async {
    List<Opinion> fetchedOpinions = [];
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    String url = baseUrl + "articles/" + articleId + "/opinions";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final opinion in responseJson["opinions"]){
          fetchedOpinions.add(Opinion(
            opinion_id: opinion["opinion_id"],
            article_id: opinion["article_id"],
            username: opinion["username"],
            user_profile_image_path: opinion["profile_image_url"],
            content: opinion["content"],
            opinion_date: opinion["date_created"],
         ));
        }
        _opinions = [...fetchedOpinions];
        notifyListeners();
      } else if (response.statusCode == 404) {
        print("Opinions not found");
        throw "Opinions not found";
      } else {
        print(response.body);
        throw "Failed to load Opinions";
      }
    } catch (error) {
      print(error);
      throw "Failed to load opinions";
    }
  }

  // Add new Opinion
   Future<void> addOpinion(String content, String articleId) async {
     print(content);
     print(articleId);

     String url = baseUrl + "article/"+articleId+"/opinions";
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String date_created = dateFormatter.format(DateTime.now());
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers["Authorization"] = token;
    request.fields["content"] = content;
    request.fields["date_created"]=date_created;
    request.fields["is_reply"]="0";
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        print("Inserted successfully");
      } else {
        print(responseJson["message"]);
        throw "Failed to insert comment";
      }
    } catch (error) {
      throw "Failed to insert comment";
    }
  }

  // Get All replies of an Opinion
  Future<void> getAllReplies(String articleId, String opinionId) async {
    List<Opinion> fetchedReplies = [];
    String url = baseUrl +  "articles/" + articleId + "/opinions" + opinionId;
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    await http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: token},
    ).then((response) {
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final opinion in responseJson["opinions"]) {
          fetchedReplies.add(Opinion(
            opinion_id: opinion["opinion_id"],
            article_id: opinion["article_id"],
            username: opinion["username"],
            user_profile_image_path: opinion["profile_image_url"],
            content: opinion["content"],
            opinion_date: opinion["date_created"],
          ));
        }
        _replies = [...fetchedReplies];
        notifyListeners();
        //return _replies;
      } else {
        print(response.body);
        throw "Failed to load replies";
      }
    }).catchError((error) {
      print(error);
      throw "Failed to load replies";
    });
  }
  
  List<Opinion> get opinions{
    return [..._opinions];
  }

}