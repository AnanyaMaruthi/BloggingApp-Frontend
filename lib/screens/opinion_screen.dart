import 'dart:convert';
import 'dart:io';
import 'package:bloggingapp/providers/opinion.dart';
import 'package:bloggingapp/providers/opinions.dart';
import 'package:bloggingapp/widgets/error_dialog.dart';
import 'package:bloggingapp/widgets/opinions_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  bool _isInit = true;
  bool _errorOpinions = false;
  bool _errorReplies = false;
  Opinion _opinions;


  Future<http.Response> _responseFuture;
  final storage = FlutterSecureStorage();

void initState() {
    super.initState();
    print("I am in opinions page");
    //_loadData();
    //_responseFuture= Provider.of<Opinions>(context).getOpinions(widget.articleId);
    //to get the opinions
    
}

//  @override
//   void didChangeDependencies() {
//     if (_isInit) {
//       _loadData();
//       setState(() {
//         _isInit = false;
//       });
//     }
//     super.didChangeDependencies();
//   }

    // Future<void> _loadData() async {
    //   final token = await storage.read(key: "token");
    // String url = baseUrl + "articles/" + widget.articleId + "opinions";
    // _responseFuture = http.get(url,headers: {HttpHeaders.authorizationHeader: token},);
    // }
// // Get Opinions
//     Provider.of<Opinions>(context).getOpinions(widget.articleId).then((data) {
//       setState(() {
//         _loadingOpinions = false;
//         //_opinions = data;
//       });
//     }).catchError((errorMessage) {
//       showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return ErrorDialog(
//               errorMessage: errorMessage,
//             );
//           });
//       setState(() {
//         _errorOpinions= true;
//       });
//     });
//    }

Widget build(BuildContext context){
   final opinions = Provider.of<Opinions>(context).getOpinions(widget.articleId);
   print("in opinion page");
   return new Scaffold(
      appBar: new AppBar(
        title: new Text('Opinions'),
      ),
      body: 
      // new FutureBuilder(
      //   future: Provider.of<Opinions>(context).getOpinions(widget.articleId) ,
      //   builder: (BuildContext context, response) {
      //     if (!response.hasData) {
      //       return const Center(
      //         child: const Text('Loading...'),
      //       );
      //     } else {
      //       //final responseJson = json.decode(response.data.body);
      //       print(response);
            // return const Center(
            //   child: const Text('gotcha'),
            // );
               new OpinionSystem(),
                  //     }
                  //   },
                  // ),
                  
                );
              }
}

// class OpinionList extends StatelessWidget {
//   final List<dynamic> opinionList;

//   OpinionList(this.opinionList);

//   List<Widget> _getChildren() {
//     List<Widget> children = [];
//     opinionList.forEach((element) {
//       children.add(
//         new ReplyTile(element['opinionId']),
//       );
//     });
//     return children;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new ListView(
//       children: _getChildren(),
//     );
//   }
// }

// class ReplyTile extends StatefulWidget {
 
//   final String opinionId;
//   ReplyTile(this.opinionId);
//   OpinionScreen _opinionScreen;
//   @override
//   State createState() => new ReplyTileState();
// }

// class ReplyTileState extends State<ReplyTile> {
//   PageStorageKey _key;
//   Future<http.Response> _responseFuture;

//   @override
//   void initState() {
//     super.initState();
//     String url = baseUrl + "articles/" + widget._opinionScreen.articleId + "/opinions/" + widget.opinionId;
//     _responseFuture =
//         http.get(url);
//   }

//   @override
//   Widget build(BuildContext context) {
//     _key = new PageStorageKey('${widget.opinionId}');
//     return new ExpansionTile(
//       key: _key,
//       title: new Text("View Replies"),
//       children: <Widget>[
//         new FutureBuilder(
//           future: _responseFuture,
//           builder:
//               (BuildContext context, AsyncSnapshot<http.Response> response) {
//             if (!response.hasData) {
//               return const Center(
//                 child: const Text('Loading...'),
//               );
//             } else if (response.data.statusCode != 200) {
//               return const Center(
//                 child: const Text('Error loading data'),
//               );
//             } else {
//               List<dynamic> responseJson = json.decode(response.data.body);
//               List<Widget> replyList = [];
//               responseJson.forEach((element) {
//                 replyList.add(new ListTile(
//                   dense: true,
//                   title: new Text(element['content']),
//                 ));
//               });
//               return new Column(children: replyList);
//             }
//           },
//         )
//       ],
//     );
// }

//}
