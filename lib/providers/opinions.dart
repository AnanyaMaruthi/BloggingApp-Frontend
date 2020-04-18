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

class Opinions with ChangeNotifier {
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
    String url = baseUrl + "article/" + articleId + "/opinions";
    print(url);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final opinion in responseJson["opinions"]) {
          fetchedOpinions.add(Opinion(
            opinion_id: opinion["opinion_id"].toString(),
            article_id: opinion["article_id"],
            username: opinion["username"],
            user_profile_image_path: opinion["profile_image_url"],
            content: opinion["content"],
            opinion_date: DateTime.parse(opinion["date_created"]),
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
    print("I am in provider");
    print(content);
    print(articleId);

    String url = baseUrl + "article/" + articleId + "/opinions";
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String date_created = dateFormatter.format(DateTime.now());
    try{
      var response = await http.post(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {
          "content": content,
          "date_created": date_created,
          "is_reply": "0",
        },
      );
      final responseJson = json.decode(response.body);
      if(response.statusCode == 200){
        print(responseJson);
        print("Added opinion successfully");
      }else{
        print(response.body);
        print(responseJson["message"]);
        throw "Failed to add opinion";
      }
    }catch(error){
      throw error;
    }
  }

  // Get All replies of an Opinion
  Future<void> getAllReplies(String articleId, String opinionId) async {
    List<Opinion> fetchedReplies = [];
    String url = baseUrl + "articles/" + articleId + "/opinions" + opinionId;
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

  List<Opinion> get opinions {
    return [..._opinions];
  }
}
