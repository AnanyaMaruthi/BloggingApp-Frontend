import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:toast/toast.dart';

import '../models/author.dart';

class AuthorInput extends StatefulWidget {
  List<dynamic> authors;
  String collectionId;
  AuthorInput(this.authors, this.collectionId);

  @override
  _AuthorInputState createState() => _AuthorInputState();
}

class _AuthorInputState extends State<AuthorInput> {
  List<int> _newAuthors = [];
  List<int> _deletedAuthors = [];
  List<Author> _initialAuthors = [];
  List<Author> _selectedAuthors = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _initialAuthors = [...widget.authors];
      _selectedAuthors = [...widget.authors];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ChipsInput(
          initialValue: _initialAuthors,
          enabled: true,
          maxChips: 6,
          textStyle: TextStyle(
            height: 1.5,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: "Select People",
          ),
          findSuggestions: (String query) async {
            if (query.length != 0) {
              final fetchedAuthors = await Author.getSuggestions(query);
              print("fetched suggestions");
              print(fetchedAuthors);
              return fetchedAuthors;
            }
            return <Author>[];
          },
          onChanged: (data) {
            print("On changed");
            print(data);
            setState(() {
              _selectedAuthors = [...data];
            });
          },
          chipBuilder: (context, state, profile) {
            return InputChip(
              key: ObjectKey(profile),
              label: Text(profile.username),
              avatar: (
                  // to be removed
                  profile.image_url == null
                      ? CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        )
                      : CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: NetworkImage(profile.image_url),
                        )),
              onDeleted: () => state.deleteChip(profile),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
          suggestionBuilder: (context, state, profile) {
            return ListTile(
              key: ObjectKey(profile),
              leading: (
                  // to be removed
                  profile.image_url == null
                      ? CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        )
                      : CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          backgroundImage: NetworkImage(profile.image_url),
                        )),
              title: Text(profile.username),
              subtitle: Text(profile.email),
              onTap: () => state.selectSuggestion(profile),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              textColor: Theme.of(context).colorScheme.primary,
              child: Text("Edit Authors"),
              onPressed: () {
                _editAuthors(context);
                //Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              textColor: Theme.of(context).colorScheme.error,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }

  void _editAuthors(BuildContext context) {
    List<Author> temp;
    // _newAuthors = _selectedAuthors - _initialAuthors
    temp = (_selectedAuthors
        .where((element) => !_initialAuthors.contains(element))).toList();
    for (var data in temp) {
      _newAuthors.add(data.user_id);
    }
    temp = [];
    // _deletedAuthors = _initialAuthors - _selectedAuthors
    temp = (_initialAuthors
        .where((element) => !_selectedAuthors.contains(element))).toList();
    for (var data in temp) {
      _deletedAuthors.add(data.user_id);
    }
    print("New authors: " + _newAuthors.toString());
    print("Deleted authors: " + _deletedAuthors.toString());

    if (_newAuthors.length != 0) {
      Author.addAuthors(_newAuthors, widget.collectionId).then((reply) {
        print("Added");
        Toast.show("Added authors successfully!", context,
            duration: 7, gravity: Toast.BOTTOM);
        print(reply);
      }).catchError((errorMessage) {
        print(errorMessage);
        Navigator.of(context).pop();
        Toast.show(errorMessage, context, duration: 7, gravity: Toast.BOTTOM);
      });
    }
    if (_deletedAuthors.length != 0) {
      Author.deleteAuthors(_deletedAuthors, widget.collectionId).then((reply) {
        Toast.show("Removed authors successfully!", context,
            duration: 7, gravity: Toast.BOTTOM);
        print("Deleted authors");
      }).catchError((errorMessage) {
        print(errorMessage);
        Navigator.of(context).pop();
        Toast.show(errorMessage, context, duration: 7, gravity: Toast.BOTTOM);
      });
    }
  }
}
