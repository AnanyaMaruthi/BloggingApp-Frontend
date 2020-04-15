import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bloggingapp/screens/article_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/article.dart';
import '../providers/articles.dart';

class ArticleDeleteCard extends StatelessWidget {
  
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
                            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                showAlert(context, article);
              }),
              ]),
              ),
            ]))
          ],
        )),
      ),
    );
  }

  showAlert(BuildContext context, article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          titlePadding: EdgeInsets.all(0),
          title: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Delete Article...?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
          content: Text("The _article titled - " +
              article.title +
              " will be deleted. This action cannot be undone. Confirm delete?"),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              child: Text("DELETE"),
              textColor: Theme.of(context).colorScheme.error,
              onPressed: () {
                article.deleteArticle(article.article_id).then((_) {
                  print("Article deleted");
                });
                Provider.of<Articles>(context)
                    .deleteArticle(article.article_id)
                    .then((_) {
                  print("Deleted from list _article");
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text("CANCEL"),
              textColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
