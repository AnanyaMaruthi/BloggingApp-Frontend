import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../server_util.dart' as Server;

class Author {
  final int user_id;
  final String username;
  final String email;
  final String image_url;

  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static SharedPreferences _sharedPreferences;

  Author(this.user_id, this.username, this.email, this.image_url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Author &&
          runtimeType == other.runtimeType &&
          user_id == other.user_id;

  @override
  int get hashCode => username.hashCode;

  @override
  String toString() {
    return username.toString();
  }

  static Future<List<Author>> getSuggestions(String query) async {
    List<Author> fetchedAuthors = [];

    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');

    String url = baseUrl + "users?prompt=" + query;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final author in responseJson["users"]) {
          fetchedAuthors.add(Author(
            author["user_id"],
            author["username"],
            author["email"],
            author["profile_image_url"],
          ));
        }
        return fetchedAuthors;
      } else {
        print(response.body);
        throw "Failed to get suggestions";
      }
    } catch (error) {
      print(error);
      throw "Failed to get suggestions";
    }
  }

  static Future<String> addAuthors(
      List<int> authors, String collectionId) async {
    // /api/v1/collections/:collectionId/authors/
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    String base = Server.base;
    String path = "/api/v1/collections/" + collectionId + "/authors";
    var url = Uri.http(base, path);
    try {
      final response = await http.post(url,
          headers: {
            HttpHeaders.authorizationHeader: token,
            HttpHeaders.contentTypeHeader: "application/json"
          },
          body: jsonEncode({
            "authors": authors,
          }));
      print(response.body);
      final responseJson = json.decode(response.body);
      return responseJson["message"];
    } catch (error) {
      throw error;
    }
  }

  static Future<String> deleteAuthors(
      List<int> authors, String collectionId) async {
// /api/v1/collections/:collectionId/authors/
    _sharedPreferences = await _prefs;
    String token = _sharedPreferences.getString('token');
    String base = Server.base;
    String path = "/api/v1/collections/" + collectionId + "/authors";
    var url = Uri.http(base, path);
    final client = http.Client();
    try {
      final streamedResponse = await client.send(http.Request("DELETE", url)
        ..headers["authorization"] = token
        ..headers["content-type"] = "application/json"
        ..body = jsonEncode({
          "authors": authors,
        }));

      var response = await Response.fromStream(streamedResponse);
      print(response.body);
      final responseJson = json.decode(response.body);
      return responseJson["message"];
    } catch (error) {
      throw error;
    } finally {
      client.close();
    }
  }
}
