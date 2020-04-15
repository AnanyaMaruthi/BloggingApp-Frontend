import '../widgets/collection_list.dart';
import '../widgets/articles_list.dart';
import '../widgets/error_dialog.dart';

import '../providers/users.dart';
import '../providers/user.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../route_observer.dart' as route_observer;

class UserScreen extends StatefulWidget {
  static const routeName = "/user";

  final String userId;
  UserScreen(this.userId);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with TickerProviderStateMixin, RouteAware {
  User user;
  TabController _tabController;

  bool _loadingUser = true;
  bool _error = false;
  bool _isInit = true;
  ScrollController _scrollController;
  bool _sliverCollapsed = false;

  final routeObserver = route_observer.routeObserver;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    print("I am in view profile page");
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

  void _loadData() {
    Provider.of<Users>(context).fetchUserById(widget.userId).then((data) {
      setState(() {
        _loadingUser = false;
        user = data;
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

  @override
 Widget build(BuildContext context) {
    return Scaffold(
        body: (_loadingUser == true
          ? SpinKitChasingDots(
              color: Colors.teal,
            )
                : DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: 330.0,
                            floating: false,
                            pinned: true,
                            actions: _loadingUser == true ? null : <Widget>[
                            user.is_following
                ? Padding(
                  padding : EdgeInsets.all(10.0),
                  child : FlatButton(
                        color: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.all(10.0),
                        onPressed: () {
                          user.unfollowUser(user.user_id.toString()).then((_) {
                            print("Unfollowed user");
                          });
                          setState(() {
                            _loadData();
                          });
                        },
                        child: Text("Following"),
                      )
                )
              : Padding(
                padding : EdgeInsets.all(10.0),
                child : OutlineButton(
                  
                                  //color: Colors.white,
                                    color: Theme.of(context).colorScheme.primary,
                                    borderSide: BorderSide(
                                    //color: Colors.white,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                      //textColor: Colors.white,
                                       textColor: Theme.of(context).colorScheme.primary,
                                         padding: EdgeInsets.all(10.0),
                                        onPressed: () {
                                         user.followUser(user.user_id.toString()).then((_) {
                                         print("Followed user");
                                    });
                                    setState(() {
                                         _loadData();
                                      });
                                   },
                                 child: Text("Follow"),
                           ),
                         ),
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
                                                    user.profile_image_url),
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
                                                  // TODO: fix overflow
                                                  child: Text(
                                                    user.username,
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
                                                    user.email,
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
                                          user.about ?? ' ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          maxLines: 3,
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
                                                      user.followerCount
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
                                                      user.followingCount
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
                                          user.username,
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
                           ArticlesList(),
                           CollectionList(),
                          ]),
      ))));
   }
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
