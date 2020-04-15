import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/collection_screen.dart';

import '../providers/collection.dart';

class CollectionPreviewCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final _collection = Provider.of<Collection>(context);
    return SizedBox(
      height: 110,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(CollectionScreen.routeName,
              arguments: _collection.collection_id);
        },
        child: Card(
            child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                child: CachedNetworkImage(
                  imageUrl: _collection.image_url,
                  placeholder: (context, url) => Image(
                    image: AssetImage("assets/images/gradient_placeholder.png"),
                    fit: BoxFit.cover,
                    height: 80.0,
                    width: 80.0,
                  ),
                  errorWidget: (context, url, error) => Image(
                    image: AssetImage("assets/images/gradient_placeholder.png"),
                    fit: BoxFit.cover,
                    height: 80.0,
                    width: 80.0,
                  ),
                  fit: BoxFit.cover,
                  height: 80.0,
                  width: 80.0,
                )),
            Container(
                margin: EdgeInsets.fromLTRB(100.0, 10.0, 10.0, 10.0),
                child: Stack(children: <Widget>[
                  Text(
                    _collection.collection_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  _collection.description== null
                      ? Text("No description")
                      : Container(
                          alignment: Alignment(1, 1),
                          //margin :  EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: Text(_collection.description,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                            )),
                            _collection.is_owner
                      ? FlatButton(
                          disabledColor: Color(0xffAF5680),
                          disabledTextColor: Colors.white,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          onPressed: null,
                          child: Text("Owner"),
                        )
                      // Is author
                      : _collection.is_author
                          ? FlatButton(
                              disabledColor:
                                  Theme.of(context).colorScheme.secondary,
                              disabledTextColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              onPressed: null,
                              child: Text("Author"),
                            )
                          : _collection.is_following
                              ?
                              // is following
                              FlatButton(
                                  color: Theme.of(context).colorScheme.primary,
                                  textColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: EdgeInsets.all(10.0),
                                  onPressed: () {
                                    _collection
                                        .unfollowCollection(
                                            _collection.collection_id)
                                        .then((_) {
                                      print("Unfollowed collection");
                                    });
                                  },
                                  child: Text("Following"),
                                )
                              // Follower
                              : OutlineButton(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  textColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding: EdgeInsets.all(10.0),
                                  onPressed: () {
                                    _collection
                                        .followCollection(
                                            _collection.collection_id)
                                        .then((_) {
                                      print("Followed collection");
                                    });
                                  },
                                  child: Text("Follow"),
                                ),
                          ]),
                        ),
                ]))
          ],
        )),
      ),
    );
  }
}
