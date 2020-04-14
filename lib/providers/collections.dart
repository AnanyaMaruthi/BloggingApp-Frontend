import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../server_util.dart' as Server;

import './collection.dart';
import '../models/author.dart';

class Collections with ChangeNotifier {
  static const baseUrl = Server.SERVER_IP + "/api/v1/";
  
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  List<Collection> _collections = [];

  List<Collection> get collections {
    return [..._collections];
  }

  // Get User owned or authored collections
  Future<void> getUserCollections() async {
    List<Collection> fetchedCollections = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    final userId = _sharedPreferences.getString('userId');

    String url = baseUrl + "user/" + userId.toString() + "/collections";

    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final collection in responseJson["collections"]) {
          fetchedCollections.add(Collection(
            collection_id: collection["collection_id"],
            user_id: collection["user_id"],
            collection_name: collection["collection_name"],
            image_url: collection["image_url"],
            description: collection["description"],
            is_owner: collection["is_owner"] == 0 ? false : true,
            is_author: collection["is_author"] == 0 ? false : true,
            is_following: false,
          ));
        }
        _collections = [...fetchedCollections];
        notifyListeners();
      } else {
        print(response.body);
        throw "Failed to load collections";
      }
    } catch (error) {
      print(error);
      throw "Failed to load collections";
    }
  }

// Get collection by ID
// Change name to get
  Future<Collection> fetchCollectionById(String collectionId) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String url = baseUrl + "collections/" + collectionId;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        List<Author> authors = [];
        final responseJson = json.decode(response.body);
        print(responseJson);
        final collectionData = responseJson["collection"];
        final authorData = responseJson["authors"];
        print("Collection data");
        print(collectionData);
        print("Author data");
        print(authorData);
        for (final author in authorData) {
          authors.add(Author(
            author["user_id"],
            author["username"],
            author["email"],
            author["image_url"],
          ));
        }
        Collection collection = Collection(
          collection_id: collectionData["collection_id"],
          collection_name: collectionData["collection_name"],
          user_id: collectionData["user_id"],
          image_url: collectionData["image_url"],
          description: collectionData["description"],
          is_owner: collectionData["is_owner"] == 0 ? false : true,
          is_author: collectionData["is_author"] == 0 ? false : true,
          is_following: collectionData["is_following"] == 0 ? false : true,
          authors: authors,
        );
        print("Collection Authors");
        print(collection.authors);
        return collection;
      } else if (response.statusCode == 404) {
        print("Collection not found");
        throw "Collection not found";
      } else {
        print(response.body);
        throw "Failed to load collection";
      }
    } catch (error) {
      print(error);
      throw "Failed to load collection";
    }
  }

  // Add new collection
  Future<String> addCollection(Map<String, dynamic> data, File image) async {
    print(data);
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    final userId = _sharedPreferences.getString("userId");
    String collectionId =
        userId.toString() + (DateTime.now().millisecond).toString();
    String url = baseUrl + "collections";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["collection_id"] = collectionId;
    request.fields["user_id"] = userId;
    request.fields["collection_name"] = data["collectionName"];
    request.fields["description"] = data["description"];
    request.fields["image_url"] = " ";
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        return collectionId;
      } else {
        print(responseJson["message"]);
        throw "Failed to create collection";
      }
    } catch (error) {
      throw "Failed to create collection";
    }
  }

// update collection
  Future<String> updateCollection(Map<String, dynamic> data, File image) async {
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');
    String collectionId = data["collectionId"];
    String url = baseUrl + "collections/" + collectionId;
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["description"] = data["description"];
    request.fields["image_url"] = " ";
    request.fields["tags"] = data["tags"];
    try {
      dynamic response = await request.send();
      response = await response.stream.bytesToString();
      final responseJson = json.decode(response);
      if (responseJson["error"] == false) {
        return "Successfully updated collection";
      } else {
        print(responseJson["message"]);
        throw "Failed to update collection";
      }
    } catch (error) {
      print(error);
      throw "Failed to update collection";
    }
  }

  // Search Collections
  Future<void> searchCollections(String query) async {
    List<Collection> fetchedCollections = [];
    _sharedPreferences = await _prefs;
    final token = _sharedPreferences.getString('token');

    String url = baseUrl + "collections?q=" + query;
    print(url);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        for (final collection in responseJson["collections"]) {
          fetchedCollections.add(Collection(
            collection_id: collection["collection_id"],
            user_id: collection["user_id"],
            collection_name: collection["collection_name"],
            image_url: collection["image_url"],
            description: collection["description"],
            is_owner: collection["is_owner"] == 0 ? false : true,
            is_author: collection["is_author"] == 0 ? false : true,
            is_following: collection["is_following"] == 0 ? false : true,
          ));
        }
        _collections = [...fetchedCollections];
      } else {
        print(response.body);
        throw "Failed to load collections";
      }
    } catch (error) {
      print("Failed to load collections");
      throw "Failed to load collections";
    }
  }
}
