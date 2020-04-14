import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../server_util.dart' as Server;
import './article.dart';

class Articles with ChangeNotifier {
  static const baseUrl = Server.SERVER_IP + "/api/v1/";

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  List<Article> _articles = [];

  Article findById(String article_id) {
    return _articles.firstWhere((article) => article.article_id == article_id);
  }

  List<Article> get articles {
    return [..._articles];
  }

  Future<void> deleteArticle(String articleId) async {
    print("Delete from screen");
    _articles.removeWhere((article) => article.article_id == articleId);
    notifyListeners();
  }

  // Insert Article
  Future<String> addArticle(Map<String, dynamic> data, File image) async {
    String url = baseUrl + "articles";
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    final userId = _sharedPreferences.getString('userId');

    String articleId =
        userId.toString() + (DateTime.now().millisecondsSinceEpoch).toString();
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String dateCreated = dateFormatter.format(DateTime.now());

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["article_id"] = articleId;
    request.fields["collection_id"] = data["collectionId"];
    request.fields["user_id"] = userId;
    request.fields["title"] = data["title"];
    request.fields["content"] = data["content"];
    request.fields["image_path"] = " ";
    request.fields["views_count"] = "0";
    request.fields["date_created"] = dateCreated;
    request.fields["date_updated"] = dateCreated;
    request.fields["tags"] = data["tags"];
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        return articleId;
      } else {
        print(responseJson["message"]);
        throw "Failed to add article";
      }
    } catch (error) {
      print(error);
      throw "Failed to add article";
    }
  }

  // Update Article
  Future<String> updateArticle(Map<String, dynamic> data, File image) async {
    String url = baseUrl + "articles/" + data["article_id"];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');

    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String dateUpdated = dateFormatter.format(DateTime.now());

    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["title"] = data["title"];
    request.fields["content"] = data["content"];
    request.fields["image_path"] = data["image_path"];
    request.fields["date_updated"] = dateUpdated;
    request.fields["tags"] = data["tags"];
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        print("Updated");
        return data["article_id"];
      } else {
        print(responseJson["message"]);
        throw "Failed to update article";
      }
    } catch (error) {
      print(error);
      throw "Failed to update article";
    }
  }

  // Get article by ID
  Future<Article> getArticleById(String articleId) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "articles/" + articleId;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final data = responseJson["article"];
        Article article = Article(
          article_id: data["article_id"],
          collection_id: data["collection_id"],
          user_id: data["user_id"],
          title: data["title"],
          content: data["content"],
          image_path: data["image_path"],
          date_created: DateTime.parse(data["date_created"]),
          date_updated: DateTime.parse(data["date_updated"]),
          tags: data["tags"],
          is_bookmarked: data["is_bookmarked"] == 0 ? false : true,
          is_author: data["is_author"] == 0 ? false : true,
          author: data["author"],
          profile_image_url: data["profile_image_url"],
        );
        print(data["author"]);
        notifyListeners();
        return article;
      } else if (response.statusCode == 404) {
        print("Article not found");
        throw "Article not found";
      } else {
        print(response.body);
        throw "Failed to load article";
      }
    } catch (error) {
      print(error);
      throw "Failed to load article";
    }
  }

  // Get Feed Articles
  Future<void> getFeedArticles() async {
    List<Article> fetchedArticles = [];
    String url = baseUrl + "user/feed";
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    await http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: token},
    ).then((response) {
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final article in responseJson["articles"]) {
          fetchedArticles.add(Article(
            article_id: article["article_id"],
            user_id: article["user_id"],
            collection_id: article["collection_id"],
            title: article["title"],
            image_path: article["image_path"],
            is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
            date_created: DateTime.parse(article["date_created"]),
            author: article["author"],
            profile_image_url: article["profile_image_url"],
          ));
        }
        _articles = [...fetchedArticles];
        notifyListeners();
      } else {
        print(response.body);
        throw "Failed to load feed";
      }
    }).catchError((error) {
      print(error);
      throw "Failed to load feed";
    });
  }

  // Get User authored articles
  Future<void> getUserArticles() async {
    List<Article> fetchedArticles = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    final userId = _sharedPreferences.getString('userId');

    String url = baseUrl + "user/" + userId.toString() + "/articles";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final article in responseJson["articles"]) {
          fetchedArticles.add(Article(
            article_id: article["article_id"],
            user_id: article["user_id"],
            collection_id: article["collection_id"],
            title: article["title"],
            image_path: article["image_path"],
            is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
            date_created: DateTime.parse(article["date_created"]),
            author: article["author"],
            profile_image_url: article["profile_image_url"],
          ));
        }
        _articles = [...fetchedArticles];
        notifyListeners();
      } else {
        print(response.body);
        throw "Failed to load articles";
      }
    } catch (error) {
      print(error);
      throw "Failed to load articles";
    }
  }

// Get bookmarked articles
  Future<void> getBookmarkedArticles() async {
    List<Article> fetchedArticles = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "user/bookmarks";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final article in responseJson["articles"]) {
          fetchedArticles.add(Article(
            article_id: article["article_id"],
            user_id: article["user_id"],
            collection_id: article["collection_id"],
            title: article["title"],
            image_path: article["image_path"],
            is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
            date_created: DateTime.parse(article["date_created"]),
            author: article["author"],
            profile_image_url: article["profile_image_url"],
          ));
        }
        _articles = [...fetchedArticles];
      } else {
        print(response.body);
        throw "Failed to load articles";
      }
    } catch (error) {
      print(error);
      throw "Failed to load articles";
    }
  }

  // Get articles of a collection
  Future<void> getCollectionArticles(String collectionId) async {
    List<Article> fetchedArticles = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "collections/" + collectionId + "/articles";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final article in responseJson["articles"]) {
          fetchedArticles.add(Article(
            article_id: article["article_id"],
            user_id: article["user_id"],
            collection_id: article["collection_id"],
            title: article["title"],
            image_path: article["image_path"],
            is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
            date_created: DateTime.parse(article["date_created"]),
            author: article["author"],
            profile_image_url: article["profile_image_url"],
          ));
        }
        _articles = [...fetchedArticles];
      } else {
        print(response.body);
        throw "Failed to load articles";
      }
    } catch (error) {
      print(error);
      ;
      throw "Failed to load articles";
    }
  }

// Search Articles
  Future<void> searchArticles(String query) async {
    List<Article> fetchedArticles = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "articles?q=" + query;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final article in responseJson["articles"]) {
          fetchedArticles.add(Article(
            article_id: article["article_id"],
            user_id: article["user_id"],
            collection_id: article["collection_id"],
            title: article["title"],
            image_path: article["image_path"],
            is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
            date_created: DateTime.parse(article["date_created"]),
            author: article["author"],
            profile_image_url: article["profile_image_url"],
          ));
        }
        _articles = [...fetchedArticles];
      } else {
        print(response.body);
        throw "Failed to load articles";
      }
    } catch (error) {
      print(error);
      throw "Failed to load collections";
    }
  }
}
