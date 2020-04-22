import 'package:bloggingapp/providers/article.dart';
import 'package:bloggingapp/providers/articles.dart';
import 'package:bloggingapp/providers/opinions.dart';
import 'package:bloggingapp/screens/user_screen.dart';
import 'package:bloggingapp/widgets/error_dialog.dart';
import 'package:bloggingapp/widgets/reply_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/opinion.dart';

class OpinionPreviewCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final opinion = Provider.of<Opinion>(context);
    //final article = Provider.of<Article>(context);

    final photo = new Container(
      margin: new EdgeInsets.symmetric(vertical: 16.0),
      alignment: FractionalOffset.centerLeft,
      child: new Image(
        image: NetworkImage(opinion.user_profile_image_path),
        height: 60,
        width: 60,
      ),
    );
    final contentStyle = TextStyle(color: Colors.black, fontSize: 14.0);
    final usernameStyle = TextStyle(fontSize: 14.0, color: Colors.blue, fontWeight: FontWeight.bold,);
    final opinionDateStyle = TextStyle(fontSize: 12.0, color: Colors.black45);
    final card = new Container(
        margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 0.0),
        child: GestureDetector(
          onLongPress: ()
          { print("longg press");
          print(opinion.opinion_id);
          print(opinion.article_id);
        if(isAuthor(context, opinion) == true){
           _showDeleteOpinionDialog(context, opinion);
          }
          },
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: new Text(
                '@' + opinion.username,
                style: usernameStyle,
              ),
              
              onTap: () {Navigator.of(context).pushNamed(
             UserScreen.routeName,
              arguments: opinion.user_id.toString());
              },
            ),
            SizedBox(height: 10),
              new Text(
              opinion.content,
              style: contentStyle,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                new Text(
                  DateFormat.yMd()
                      .add_jm()
                      .format(opinion.opinion_date)
                      .toString(),
                  style: opinionDateStyle,
                ),
              ],
            )
          ],
        )));
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        child: new Stack(
          children: <Widget>[photo,card, Divider()],
          //ReplyTile(opinion.opinion_id, opinion.article_id)
        ),
      ),
    );
  }

  _showDeleteOpinionDialog(BuildContext context, Opinion opinion) {
    
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
              'Confirm Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
          content: Text(
              "You are about to delete this opinion "),
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
                opinion.deleteOpinion(opinion.opinion_id, opinion.article_id).then((_){
                  print("in onpress delete");
                });
                Provider.of<Opinions>(context)
                    .deleteOpinion(opinion.opinion_id)
                    .then((_) {
                  print("Deleted from list opinion");
                });
                //Provider.of<Opinions>(context).
                // _collection
                //     .deleteCollection(_collection.collection_id)
                //     .then((_) {
                //   print("Collection deleted");
                //});
                Navigator.of(context).pop();
                // Navigator.of(context)
                //     .pushReplacementNamed(ProfileScreen.routeName);
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

bool isAuthor(BuildContext context, Opinion opinion){
  Article _article;
  bool author= true;
  Provider.of<Articles>(context)
        .getArticleById(opinion.article_id)
        .then((article) {
        _article = article;
        author = article.is_author;
        print(_article);
      })
    .catchError((errorMessage) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorMessage: errorMessage,
            );
          });
    });
    //print(_article.is_author);
    return author;
}
}