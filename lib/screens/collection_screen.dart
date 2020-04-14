
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../route_observer.dart' as route_observer;

import '../screens/collection_edit_screen.dart';
import '../screens/article_delete_screen.dart';
import '../screens/article_insert_screen.dart';

// Widgets
import '../widgets/collection_details_card.dart';
import '../widgets/articles_list.dart';
import '../widgets/author_input.dart';
import '../widgets/error_dialog.dart';

// Providers
import '../providers/collections.dart';
import '../providers/collection.dart';
import '../providers/articles.dart';

class CollectionScreen extends StatefulWidget {
  static const routeName = "/collection";
  String collectionId;
  CollectionScreen(this.collectionId);
  @override
  _CollectionScreenState createState() => _CollectionScreenState();
  
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  Collection _collection;
  ScrollController _controller = new ScrollController();

  bool _isInit = true;
  bool _loadingCollection = true;
  bool _loadingArticles = true;
  bool _errorCollection = false;
  bool _errorArticles = false;
  List<dynamic> _authors = [];

   bool isScrollingDown = false;
  bool _changeAppbarText = false;

  final routeObserver = route_observer.routeObserver;

   @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
    super.dispose();
  }

   void myScroll() async {
    _controller.addListener(() {
      if (_controller.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
           setState(() {
              _changeAppbarText = true;
           });
            print("Scrolling down"); 
        }
      }
      if (_controller.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
           setState(() {
              _changeAppbarText = true;
           });
          print("Scrolling up");
        }
      }
    });
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
    _loadData();
    super.didPopNext();
  }

  void _setAuthors(List<dynamic> authors) {
    setState(() {
      _authors = [...authors];
    });
  }

  void _loadData() {
    // Get collection details
    Provider.of<Collections>(context)
        .fetchCollectionById(widget.collectionId)
        .then((data) {
      setState(() {
        print("data");
        print(data);
        _loadingCollection = false;
        _collection = data;
        _authors = data.authors;
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
        _errorCollection = true;
      });
    });
    // Get articles of this collection
    Provider.of<Articles>(context)
        .getCollectionArticles(widget.collectionId)
        .then((_) {
      setState(() {
        _loadingArticles = false;
      });
    }).catchError((errorMessage) {
      setState(() {
        _errorArticles = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
     appBar:AppBar(
          title:(_changeAppbarText==true
          ? Text(_collection.collection_name):Text("Collection...")),
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
          actions: _loadingCollection==true?null: _collection.is_owner?
          <Widget>[ 
            PopupMenuButton(
              onSelected: (int selectedValue) {
                if (selectedValue == 0) {
                  _showDeleteCollectionDialog(context);
                } else if (selectedValue == 1) {
                  Navigator.of(context).pushNamed(
                    EditCollection.routeName,
                    arguments: _collection,
                  );
                } else if (selectedValue == 2) {
                  Navigator.of(context)
                      .pushNamed(ArticleDeleteScreen.routeName);
                } else if (selectedValue == 3) {
                  _showEditAuthorDialog();
                }
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                PopupMenuItem(child: Text('Delete Collection'), value: 0),
                PopupMenuItem(child: Text('Edit Collection'), value: 1),
                PopupMenuItem(child: Text('Delete Article'), value: 2),
                PopupMenuItem(child: Text('Authors'), value: 3),
              ],
            ),
          ]:null),
        
         
            body:CustomScrollView(
            //physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            slivers: <Widget>[
                    SliverToBoxAdapter(
                    child: SizedBox(
                    height: 1000,
                    child: (_errorCollection == true
                    ? Center(
                          child: Text("An error occured"),
                       )
                   : (_loadingCollection == true
                      ? SpinKitChasingDots(
                               color: Colors.teal,
                         )
                       :
                   Column(
                      children: [
                     ChangeNotifierProvider.value(
                      value: _collection,
                      child: CollectionDetailsCard(),
                      
                    ),
                    (_errorArticles == true
                        ? Center(
                            child: Text("An error occured"),
                          )
                        : (_loadingArticles == true
                            ? SpinKitWanderingCubes(
                                color: Colors.teal,
                              )
                            : Flexible(
                                child: ArticlesList(),
                              ))),
                  ],
                ))),
      ),
    ),
  ],
 ),
  
   floatingActionButton: (_loadingCollection == true
          ? null
          : (_collection.is_author == true || _collection.is_owner == true
              ? FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        ArticleInsertScreen.routeName,
                        arguments: _collection.collection_id);
                  },
                  child: Icon(Icons.add),
                  tooltip: "Add Articles",
                )
              : null)),
    );
    
  }

  _showEditAuthorDialog() {
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Edit Authors...',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                AuthorInput(
                  _authors,
                  widget.collectionId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showDeleteCollectionDialog(BuildContext context) {
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
              "You are about to delete this collection and all articles associated with it. This action cannot be undone."),
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
                _collection
                    .deleteCollection(_collection.collection_id)
                    .then((_) {
                  print("Collection deleted");
                });
                Navigator.of(context).pop();
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
}