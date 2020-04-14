import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../server_util.dart' as Server;

class Article with ChangeNotifier {
  final String article_id;
  final String collection_id;
  final int user_id;
  final DateTime date_created;
  String title;
  String content;
  bool published;
  String image_path;
  DateTime date_updated;
  bool is_bookmarked;
  String tags;
  bool is_author;
  String author;
  String profile_image_url;

  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  Article({
    @required this.article_id,
    @required this.collection_id,
    @required this.user_id,
    @required this.title,
    this.content,
    this.published,
    this.image_path,
    this.date_created,
    this.date_updated,
    this.is_bookmarked,
    this.tags,
    this.is_author,
    this.author,
    this.profile_image_url,
  });

  //Delete article
  Future<void> deleteArticle(String articleId) async {
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    String url = baseUrl + "articles/" + articleId;
    print(url);
    try {
      final response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      print("Delete please babeyy");
      print(response);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Add bookmark
  Future<void> addBookmark(String articleId) async {
    String url = baseUrl + "user/bookmarks/" + articleId;
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    try {
      final response = await http.post(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      // final responseJson = json.decode(response.body);
      print(response.body);
      is_bookmarked = true;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String articleId) async {
    String url = baseUrl + "user/bookmarks/" + articleId;
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    try {
      final response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      // final responseJson = json.decode(response.body);
      print(response.body);
      is_bookmarked = false;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void setUnsetbookmark() {
    is_bookmarked = !is_bookmarked;
    notifyListeners();
  }
}
