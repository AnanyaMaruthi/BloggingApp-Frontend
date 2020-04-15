import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/collection.dart';

class CollectionDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _collection = Provider.of<Collection>(context);

    // List<Widget> authorChips = [];
    // for (final author in _collection.authors) {
    //   print(author.user_id);
    //   print(author.username);
    //   print(author.image_url);
    //   authorChips.add(
    //     Chip(
    //       avatar: CircleAvatar(
    //         backgroundColor: Theme.of(context).primaryColor,
    //         // backgroundImage: NetworkImage(author.image_url),
    //         child: Text("A"),
    //       ),
    //       label: Text(author.username),
    //     ),
    //   );
    // }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: (Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Center(
              child: Text(
                _collection.collection_name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Container(
              child: CachedNetworkImage(
                imageUrl: _collection.image_url,
                placeholder: (context, url) => null,
                errorWidget: (context, url, error) => null,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _collection.description,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Authors row
          // Row(
          //   children: authorChips,
          // ),
          Container(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _collection.is_following
                      ? FlatButton(
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.all(10.0),
                          onPressed: () {
                            _collection
                                .unfollowCollection(_collection.collection_id)
                                .then((_) {
                              print("Unfollowed collection");
                            });
                          },
                          child: Text("Following"),
                        )
                      : OutlineButton(
                          color: Colors.blue,
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textColor: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.all(10.0),
                          onPressed: () {
                            _collection
                                .followCollection(_collection.collection_id)
                                .then((_) {
                              print("Followed collection");
                            });
                          },
                          child: Text("Follow"),
                        ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
