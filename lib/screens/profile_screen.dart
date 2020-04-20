import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

// TODO: Refactor

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
  ScrollController _scrollController;
  bool _sliverCollapsed = false;
  double _sliverbarHeight;

  final routeObserver = route_observer.routeObserver;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _sliverbarHeight = 300;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadData();
    super.didPopNext();
  }

  _scrollListener() {
    if (_scrollController.offset > 200 &&
        !_scrollController.position.outOfRange) {
      if (!_sliverCollapsed) {
        // do what ever you want when silver is collapsing !
        print("Collapsing");
        // myTitle = "silver collapsed !";
        _sliverCollapsed = true;
        setState(() {});
      }
    }
    if (_scrollController.offset <= 200 &&
        !_scrollController.position.outOfRange) {
      if (_sliverCollapsed) {
        // do what ever you want when silver is expanding !
        print("Expanding");
        // myTitle = "silver expanded !";
        _sliverCollapsed = false;
        setState(() {});
      }
    }
  }

  void _loadData() {
// Get profile details
    Provider.of<Users>(context).getProfile().then((data) {
      setState(() {
        _loadingProfile = false;
        _user = data;
        setState(() {
          _sliverbarHeight = 300 + (_user.about.length ~/ 30) * 10.0;
        });
        print(_sliverbarHeight);
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
    return Scaffold(
        body: (_errorProfile == true
            ? Center(
                child: Text("An error occured"),
              )
            : (_loadingProfile == true
                ? SpinKitChasingDots(
                    color: Theme.of(context).colorScheme.primary,
                  )
                : DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: _sliverbarHeight,
                            floating: false,
                            pinned: true,
                            actions: <Widget>[
                              PopupMenuButton(
                                onSelected: (int selectedValue) {
                                  if (selectedValue == 0) {
                                    Navigator.of(context).pushNamed(
                                        ProfileEditScreen.routeName,
                                        arguments: _user);
                                  } else {
                                    Navigator.of(context)
                                        .pushNamed(ChangePassword.routeName);
                                  }
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                ),
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                      child: Text('Edit Profile'), value: 0),
                                  PopupMenuItem(
                                      child: Text('Change Password'), value: 1),
                                ],
                              )
                            ],
                            flexibleSpace: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xff191654),
                                      Color(0xff43c6ac),
                                      // Color(0xff6dffe1),
                                    ]),
                              ),
                              child: FlexibleSpaceBar(
                                  centerTitle: false,
                                  background: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 70),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Color(0xee191654),
                                                backgroundImage: NetworkImage(
                                                    _user.profile_image_url),
                                                radius: 60,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 10, 2),
                                                  child: Text(
                                                    _user.username,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                      fontSize: 25.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 2, 10, 10),
                                                  child: Text(
                                                    _user.email,
                                                    style: TextStyle(
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 20),
                                        child: Text(
                                          _user.about ?? ' ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      _user.followerCount
                                                              .toString() +
                                                          " followers",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      _user.followingCount
                                                              .toString() +
                                                          " following",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: (_sliverCollapsed == true
                                      ? Text(
                                          _user.username,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 20,
                                          ),
                                        )
                                      : null)),
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              TabBar(
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
                            pinned: true,
                          ),
                        ];
                      },
                      body: TabBarView(
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
                    )))));
  }
}

//Choice class
class Choice {
  Choice({this.title, this.icon});
  String title;
  IconData icon;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xff191654),
              Color(0xff43c6ac),
              // Color(0xff6dffe1),
            ]),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
