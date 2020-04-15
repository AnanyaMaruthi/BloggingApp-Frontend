import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:provider/provider.dart';
import '../route_observer.dart' as route_observer;

import '../screens/profile_edit_screen.dart';
import '../screens/change_password.dart';

import '../widgets/collection_list.dart';
import '../widgets/articles_list.dart';
import '../widgets/error_dialog.dart';

import '../providers/users.dart';
import '../providers/user.dart';
import '../providers/articles.dart';
import '../providers/collections.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profile";
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, RouteAware {
  bool _loadingProfile = true;
  bool _loadingArticles = true;
  bool _loadingCollections = true;
  bool _isInit = true;
  bool _errorProfile = false;
  bool _errorArticle = false;
  bool _errorCollections = false;
  User _user;
  TabController _tabController;
  ScrollController _scrollViewController;

  final routeObserver = route_observer.routeObserver;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _scrollViewController.addListener(() => setState(() {}));
    super.initState();
    print("I am in profile page");
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
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadData();
    super.didPopNext();
  }

  void _loadData() {
// Get profile details
    Provider.of<Users>(context).getProfile().then((data) {
      setState(() {
        _loadingProfile = false;
        _user = data;
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
        _errorProfile = true;
      });
    });

    // Get authored articles
    Provider.of<Articles>(context).getUserArticles().then((_) {
      setState(() {
        _loadingArticles = false;
      });
    }).catchError((errorMessage) {
      setState(() {
        _errorArticle = true;
      });
    });

    // Get owned / authored collections
    Provider.of<Collections>(context).getUserCollections().then((_) {
      setState(() {
        _loadingCollections = false;
      });
    }).catchError((errorMessage) {
      setState(() {
        _errorCollections = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var flexibleSpaceWidget = _loadingProfile == true
        ? null
        : new SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xfff3f7f6),
            leading: new Container(),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80.0),
              child: Text(''),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Row(
                children: <Widget>[
                  Container(
                    //  padding: EdgeInsets.all(10),
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: CircleAvatar(
                      backgroundColor: Color(0xee191654),
                      backgroundImage: NetworkImage(_user.profile_image_url),
                      radius: 60,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 2),
                        child: Text(
                          _user.username,
                          style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 2, 10, 10),
                        child: Text(
                          _user.email,
                          style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));

    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
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
            PopupMenuButton(
              onSelected: (int selectedValue) {
                if (selectedValue == 0) {
                  Navigator.of(context)
                      .pushNamed(ProfileEditScreen.routeName, arguments: _user);
                } else {
                  Navigator.of(context).pushNamed(ChangePassword.routeName);
                }
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                PopupMenuItem(child: Text('Edit Profile'), value: 0),
                PopupMenuItem(child: Text('Change Password'), value: 1),
              ],
            ),
          ],
        ),
        body: (_errorProfile == true
            ? Center(
                child: Text("An error occured"),
              )
            : (_loadingProfile == true
                ? SpinKitChasingDots(
                    color: Colors.teal,
                  )
                : NestedScrollView(
                    controller: _scrollViewController,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        flexibleSpaceWidget,
                      ];
                    },
                    body: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 30),
                        ),
                        Container(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                            child: Text(
                              _user.about ?? ' ',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                        StickyHeader(
                          header: Container(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          _user.followerCount.toString() +
                                              " followers",
                                          style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          _user.followingCount.toString() +
                                              " following",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          content: Container(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary),
                          child: TabBar(
                            indicatorColor:
                                Theme.of(context).colorScheme.onPrimary,
                            controller: _tabController,
                            tabs: [
                              Tab(
                                text: "Articles",
                              ),
                              Tab(text: "Collections"),
                            ],
                          ),
                        ),
                        new Expanded(
                          child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                (_errorArticle == true
                                    ? Center(
                                        child: Text("An error occured"),
                                      )
                                    : (_loadingArticles == true
                                        ? SpinKitDoubleBounce(
                                            color: Colors.teal,
                                          )
                                        : ArticlesList())),
                                (_errorCollections == true
                                    ? Center(
                                        child: Text("An error occured"),
                                      )
                                    : (_loadingCollections == true
                                        ? SpinKitDoubleBounce(
                                            color: Colors.teal,
                                          )
                                        : CollectionList())),
                              ]),
                        )
                      ],
                    )))));
  }
}

class Choice {
  Choice({this.title, this.icon});
  String title;
  IconData icon;
}
