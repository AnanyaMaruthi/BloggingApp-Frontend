import 'package:bloggingapp/screens/article_delete_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import './screens/home_screen.dart';
import './screens/profile_edit_screen.dart';
import './screens/article_screen.dart';
import './screens/collection_screen.dart';
import './screens/bookmarks_screen.dart';
import './screens/explore_screen.dart';
import './screens/profile_screen.dart';
import './screens/article_insert_screen.dart';
import './screens/article_edit_screen.dart';
import './screens/collection_edit_screen.dart';
import './screens/collection_insert_screen.dart';
import './screens/login_screen.dart';
import './screens/user_screen.dart';
import './screens/change_password.dart';
import './screens/splash_screen.dart';

// Providers
import './providers/articles.dart';
import './providers/collections.dart';
import './providers/users.dart';
import './providers/userAuthentication.dart';

import './route_observer.dart' as route_observer;
import './app_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeObserver = route_observer.routeObserver;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Authentication(),
        ),
        ChangeNotifierProvider.value(
          value: Users(),
        ),
        ChangeNotifierProvider.value(
          value: Articles(),
        ),
        ChangeNotifierProvider.value(
          value: Collections(),
        )
      ],
      child: MaterialApp(
        navigatorObservers: <NavigatorObserver>[routeObserver],
        title: "Blogging App",
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            SplashScreen.routeName: (context) => SplashScreen(),
            LoginScreen.routeName: (context) => LoginScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            BookmarkScreen.routeName: (context) => BookmarkScreen(),
            ExploreScreen.routeName: (context) => ExploreScreen(),
            // Collection routes
            CollectionScreen.routeName: (context) =>
                CollectionScreen(settings.arguments),
            CollectionInsertScreen.routeName: (context) =>
                CollectionInsertScreen(),
            EditCollection.routeName: (context) =>
                EditCollection(settings.arguments),
            // Article routes
            ArticleScreen.routeName: (context) =>
                ArticleScreen(settings.arguments),
            ArticleInsertScreen.routeName: (context) =>
                ArticleInsertScreen(settings.arguments),
            ArticleEditScreen.routeName: (context) =>
                ArticleEditScreen(settings.arguments),
            ArticleDeleteScreen.routeName: (context) => ArticleDeleteScreen(),
            // Profile routes
            ProfileScreen.routeName: (context) => ProfileScreen(),
            ProfileEditScreen.routeName: (context) =>
                ProfileEditScreen(settings.arguments),
            ChangePassword.routeName: (context) => ChangePassword(),

            UserScreen.routeName: (context) => UserScreen(settings.arguments),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
      ),
    );
  }
}