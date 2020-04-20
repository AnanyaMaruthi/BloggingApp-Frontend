import 'dart:io';
import 'package:toast/toast.dart';
import '../widgets/image_input.dart';

import '../screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user.dart';
import '../providers/users.dart';

class ProfileEditScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  User user;
  ProfileEditScreen(this.user);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = new GlobalKey<FormState>();
  final _username = TextEditingController();
  final _about = TextEditingController();
  File uploadedImage;

  void initState() {
    super.initState();
    print("Edit Profile Page");
    _username.text = widget.user.username;
    _about.text = widget.user.about;
  }

  void setImage(File image) {
    setState(() {
      uploadedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile...'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff191654),
                  Color(0xff43c6ac),
                  // Color(0xff6dffe1),
                ]),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: _showSaveDialog,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: FittedBox(
                    child: ImageInput(
                        uploadedImage, setImage, widget.user.profile_image_url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 16.0),
                  child: TextFormField(
                      controller: _username,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value.isEmpty) return "Username cant be empty";
                        return null;
                      }),
                ),
                TextFormField(
                  maxLines: 3,
                  maxLength: 100,
                  controller: _about,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    if (uploadedImage != null) {
      print(uploadedImage.path);
    } else {
      print("no upload");
    }
    String username = _username.text;
    String about = _about.text;
    final data = {
      "username": username,
      "about": about,
      "imageUrl": widget.user.profile_image_url,
    };
    Provider.of<Users>(context)
        .updateProfile(data, uploadedImage)
        .then((message) {
      print(message);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Toast.show("Updated successfully!", context,
          duration: 7, gravity: Toast.BOTTOM);
    }).catchError((errorMessage) {
      print(errorMessage);
      // use pop
      Navigator.of(context).pop();

      Toast.show("Profile could not be edited.Please try again.", context,
          duration: 7, gravity: Toast.BOTTOM);
    });
  }

  void _showSaveDialog() {
    if (_formKey.currentState.validate()) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(
                'Update Profile...',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
            content: Text("Save changes made to your profile?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
                textColor: Theme.of(context).colorScheme.error,
                splashColor: Theme.of(context).colorScheme.error,
              ),
              FlatButton(
                child: Text("Save"),
                textColor: Theme.of(context).colorScheme.secondary,
                splashColor: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  _updateProfile();
                  // Navigator.of(context).pop();
                  //Navigator.of(context).pushReplacementNamed(ProfileScreen.routeName);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
