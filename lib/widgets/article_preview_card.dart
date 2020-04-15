import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../screens/article_screen.dart';

import '../providers/article.dart';

class ArticlePreviewCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final article = Provider.of<Article>(context);

    return SizedBox(
      height: 110,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ArticleScreen.routeName,
              arguments: article.article_id);
        },
        child: Card(
            child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                child: CachedNetworkImage(
                  imageUrl: article.image_path,
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
                    article.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  article.date_created == null
                      ? Text("No date")
                      : Container(
                          alignment: Alignment(1, 1),
                          //margin :  EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: Text(
                              "Published by " +
                                  article.author +
                                  " on " +
                                  DateFormat("dd-MM-yyyy")
                                      .format(article.date_created),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            )),
                            (article.is_bookmarked
                                ? IconButton(
                                    icon: Icon(
                                      Icons.bookmark,
                                      size: 19,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      article
                                          .removeBookmark(article.article_id)
                                          .then((_) {
                                        print("Bookmark removed");
                                      });
                                    },
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.bookmark_border,
                                      size: 19,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      article
                                          .addBookmark(article.article_id)
                                          .then((_) {
                                        print("Bookmark added");
                                      });
                                    },
                                  )),
                          ]),
                        ),
                ]))
          ],
        )),
      ),
    );
  }
}
