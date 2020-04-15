import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zefyr/zefyr.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../route_observer.dart' as route_observer;

import './article_edit_screen.dart';
import './profile_screen.dart';
import './opinion_screen.dart';

import '../widgets/error_dialog.dart';

import '../providers/articles.dart';
import '../providers/article.dart';

class ArticleScreen extends StatefulWidget {
  static const routeName = "/article";

  String articleId;
  ArticleScreen(this.articleId);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  Article _article;
  bool _loading = true;
  bool _error = false;
  bool _isInit = true;
  NotusDocument _content;
  final routeObserver = route_observer.routeObserver;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    if (_isInit) {
      _loadData();
      setState(() {
        _isInit = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    print("pop next");
    _loadData();
    super.didPopNext();
  }

  void _loadData() {
    Provider.of<Articles>(context)
        .getArticleById(widget.articleId)
        .then((article) {
      setState(() {
        _loading = false;
        _article = article;
        _content = _loadContent();
      });
    }).catchError((errorMessage) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorMessage: errorMessage,
            );
          });
      setState(() {
        _error = true;
      });
    });
  }

// Rename
  NotusDocument _loadContent() {
    var data = jsonDecode(_article.content);
    return NotusDocument.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Article..."),
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
        actions: _loading == true
            ? null
            : _article.is_author
                ? <Widget>[
                    PopupMenuButton(
                      onSelected: (int selectedValue) {
                        if (selectedValue == 0) {
                          showAlert(context, _article.article_id);
                        } else {
                          Navigator.of(context).pushNamed(
                              ArticleEditScreen.routeName,
                              arguments: _article);
                        }
                      },
                      icon: Icon(
                        Icons.more_vert,
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(child: Text('Delete Article'), value: 0),
                        PopupMenuItem(child: Text('Edit Article'), value: 1),
                      ],
                    ),
                  ]
                : null,
      ),
      body: (_error == true
          ? Center(
              child: Text("Some error occured"),
            )
          : (_loading == true
              ? SpinKitChasingDots(
                  color: Colors.teal,
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ),
                        child: Center(
                          child: Text(
                            _article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 5,
                        ),
                        child: Container(
                          // height: 200,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: _article.image_path,
                            placeholder: (context, url) => null,
                            errorWidget: (context, url, error) => null,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: ZefyrView(
                          document: _content,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 10),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: <Widget>[
                      //       Text("Published on  "),
                      //       Text(DateFormat("dd-MM-yyyy")
                      //           .format(_article.date_created)),
                      //     ],
                      //   ),
                      // ),
                      Authorcard(),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          child: SizedBox(
                            width: double.infinity,
                            child: MaterialButton(
                              color: Colors.teal,
                              padding: EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    OpinionScreen.routeName,
                                    arguments: _article.article_id);
                                print("hello");
                              },
                              child: Text(
                                "Opinions",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))),
    );
    // floatingActionButton: (_error || _loading)
    //     ? null
    //     : (_article.is_author ? plusFloatingButton() : null));
  }

  Widget Authorcard() {
    return new Card(
      color: Colors.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      //elevation: 8.0,
      //margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        //decoration: BoxDecoration(),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: _article.profile_image_url,
              placeholder: (context, url) => Image.network(
                "http://via.placeholder.com/640x360",
                fit: BoxFit.cover,
                height: 50.0,
                width: 50.0,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
              height: 50.0,
              width: 50.0,
            ),
          ),
          title: Text(
            _article.author,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            softWrap: true,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProfileScreen.routeName,
                arguments: _article.user_id);
          },
        ),
      ),
    );
  }

  showAlert(BuildContext context, article_id) {
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
          content: Text("Delete article "),
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
                _article.deleteArticle(article_id).then((_) {
                  print("Article deleted");
                });
                Provider.of<Articles>(context)
                    .deleteArticle(article_id)
                    .then((_) {
                  print("Deleted from list article");
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

  // Floating button for authors
  // Widget plusFloatingButton() {
  //   return (SpeedDial(
  //     animatedIcon: AnimatedIcons.menu_close,
  //     animatedIconTheme: IconThemeData(),
  //     curve: Curves.bounceIn,
  //     overlayColor: Colors.black,
  //     overlayOpacity: 0.5,
  //     onOpen: () => {},
  //     onClose: () => {},
  //     tooltip: 'Options',
  //     backgroundColor: Colors.teal,
  //     foregroundColor: Colors.white,
  //     elevation: 10.0,
  //     children: [
  //       SpeedDialChild(
  //         child: Icon(Icons.delete_sweep),
  //         backgroundColor: Colors.tealAccent,
  //         label: 'Delete Article',
  //         labelStyle: TextStyle(fontSize: 18.0),
  //         onTap: () => {},
  //       ),
  //       SpeedDialChild(
  //         child: Icon(Icons.edit),
  //         backgroundColor: Colors.tealAccent,
  //         label: 'Edit Article',
  //         labelStyle: TextStyle(fontSize: 18.0),
  //         onTap: () {
  //           Navigator.of(context).pushNamed(ArticleEditScreen.routeName);
  //         },
  //       ),
  //     ],
  //   ));
  // }
}
