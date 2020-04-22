import 'dart:convert';
import 'dart:io';
import 'package:bloggingapp/providers/article.dart';
import 'package:bloggingapp/providers/articles.dart';
import 'package:bloggingapp/providers/opinion.dart';
import 'package:bloggingapp/providers/opinions.dart';
import 'package:bloggingapp/widgets/drawer.dart';
import 'package:bloggingapp/widgets/error_dialog.dart';
import 'package:bloggingapp/widgets/opinions_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import '../server_util.dart' as Server;

const baseUrl = Server.SERVER_IP + "/api/v1/";

class OpinionScreen extends StatefulWidget {
  
  static const routeName = "/opinion-screen";

  String articleId;
  OpinionScreen(@required this.articleId);

  @override
  _OpinionScreenState createState() => _OpinionScreenState();
}

class _OpinionScreenState extends State<OpinionScreen> {
  
  final TextEditingController _commentController = TextEditingController();
  bool _loadingOpinions = true;
  bool _errorOpinions = false;
  bool _errorReplies = false;
  Opinion _opinions;
  Article _article;

  bool _loading = true;
  bool _isInit = true;
  bool _error = false;


void initState() {
    super.initState();
    print("I am in opinions page");
    //_loadData();
    //_responseFuture= Provider.of<Opinions>(context).getOpinions(widget.articleId);
    //to get the opinions
    
}

 @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadData();
      setState(() {
        _isInit = false;
      });
    }
    super.didChangeDependencies();
  }

void _loadData() {
    Provider.of<Opinions>(context).getOpinions(widget.articleId).then((_) {
      setState(() {
        _loading = false;
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
    Provider.of<Articles>(context)
        .getArticleById(widget.articleId)
        .then((article) {
      setState(() {
        _loading = false;
        _article = article;
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

// Widget build(BuildContext context){
//    final opinions = Provider.of<Opinions>(context).getOpinions(widget.articleId);
//    print("in opinion page");
//    return new Scaffold(
//       appBar: new AppBar(
//         title: new Text('Opinions'),
//       ),
//       body: 
//       // new FutureBuilder(
//       //   future: Provider.of<Opinions>(context).getOpinions(widget.articleId) ,
//       //   builder: (BuildContext context, response) {
//       //     if (!response.hasData) {
//       //       return const Center(
//       //         child: const Text('Loading...'),
//       //       );
//       //     } else {
//       //       //final responseJson = json.decode(response.data.body);
//       //       print(response);
//             // return const Center(
//             //   child: const Text('gotcha'),
//             // );
//                new OpinionSystem(widget.articleId),
//                   //     }
//                   //   },
//                   // ),
                  
//                 );
//               }
// }

Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f7f6),
      appBar: AppBar(
        title: Text('Opinions'),
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
      ),
      body: (_error == false
          ? (_loading == true
              ? SpinKitWanderingCubes(
                  color: Theme.of(context).primaryColor,
                )
              : new OpinionSystem(widget.articleId))
          : Center(
              child: Text("An error occured..."),
            )),
     
    );
  }
}
