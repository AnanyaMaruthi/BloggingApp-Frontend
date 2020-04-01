import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../screens/edit_profile_screen.dart';

import '../widgets/collection_list.dart';
import '../widgets/articles_list.dart';
import '../providers/users.dart';
import '../providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "/profile-page";
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

List<Choice> choices = <Choice>[
   Choice(title: 'Edit Profile', icon: Icons.person),
   Choice(title: 'Change Password', icon: Icons.vpn_key),  
];

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
    print("I am in profile page");
  }

  Choice _selectedChoice = choices[0]; // The app's "state".
  void _select(Choice choice) {
    
     if(_selectedChoice==choices[0])
      
                               {
                                        Navigator.of(context).pushNamed(
                                        EditProfile.routeName,
                                         arguments: user.user_id,
                                         );
                               }
    if(_selectedChoice==choices[1])
    {//dialog box to change password.
    }
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<Users>(context).getUserProfile();
    print(user.about); 
    return Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Text("Profile Page"),
              actions: <Widget>[
              PopupMenuButton<Choice>(
              elevation:3.2,
              onCanceled: () {
              print('You have not chosen anything');
              },
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.skip(0).map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
        ],
            ),
            body: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                          NetworkImage(user.profile_image_url),
                          radius: 60,
                        ),
                        new Text(
                          user.username,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 23.0, fontWeight: FontWeight.bold),
                        ),
                        new Text(user.about,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 6),
                          child: Container(
                            color: Colors.blueGrey[100],
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "1011" + " followers",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
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
                                          "1078" + " following",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // new SizedBox(
                        //   width: double.infinity,
                        //   child: RaisedButton(
                        //     color: Colors.transparent,
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0), side: BorderSide(color: Colors.black)),

                        //     child: new Text("Edit Profile"),
                        //     onPressed: (){
                        //       Navigator.of(context).pushNamed(EditProfile.routeName);
                        //     },
                        //   ),
                        // ),
                        new Container(
                          decoration: new BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor),
                          child: new TabBar(controller: _tabController, tabs: [
                            Tab(text: "Articles"),
                            Tab(text: "Collections"),
                          ]),
                        ),
                        new Expanded(
                          child:TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                ArticlesList(),
                                CollectionList(),
                              ]),
                        )
                      ],
                    ),
                  ),
                ]
            ),
          ),

        ],
      );

  }
 }   
  //Choice class
  class Choice {
   Choice({this.title, this.icon});
   String title;
   IconData icon;
    
}

