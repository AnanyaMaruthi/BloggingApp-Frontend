import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../server_util.dart' as Server;
import './opinion.dart';

class Opinions with ChangeNotifier{
  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  final storage = FlutterSecureStorage();
  List<Opinion> _opinions = [];
  List<Opinion> _replies = [];

  // Get Opinions of an article
  Future<void> getOpinions(String articleId) async {
    List<Opinion> fetchedOpinions = [];
    final token = await storage.read(key: "token");
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
  Future<String> addOpinion(Map<String, dynamic> data) async {
    print(data);
    final token = await storage.read(key: "token");
    final userId = await storage.read(key: "userId");
    final articleId = await storage.read(key: "articleId");

    String url = baseUrl +  "articles/" + articleId + "opinions";
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String dateCreated = dateFormatter.format(DateTime.now());
    String isReply= (data["is_reply"]=="1"?"1":"0");
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers["Authorization"] = token;
    request.fields["user_id"] = userId;
    request.fields["article_id"] = articleId;
    request.fields["content"] = data["content"];
    request.fields["date_created"] = dateCreated;
    request.fields["is_reply"]=isReply;
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        return "Successfully inserted opinion";
      } else {
        print(responseJson["message"]);
        throw "Failed to insert opinion";
      }
    } catch (error) {
      throw "Failed to insert opinion";
    }
  }

  // Get All replies of an Opinion
  Future<void> getAllReplies(String articleId, String opinionId) async {
    List<Opinion> fetchedReplies = [];
    String url = baseUrl +  "articles/" + articleId + "/opinions" + opinionId;
    final token = await storage.read(key: "token");
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