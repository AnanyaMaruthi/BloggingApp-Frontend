import 'dart:convert';
import 'package:bloggingapp/widgets/opinion_preview_card.dart';
import 'package:bloggingapp/widgets/reply_card.dart';
import 'package:provider/provider.dart';
import 'package:bloggingapp/providers/opinions.dart';
import 'package:bloggingapp/screens/opinion_screen.dart';
import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import '../server_util.dart' as Server;

class ReplyTile extends StatefulWidget {
 
  final String opinionId,articleId;
  ReplyTile(this.opinionId, this.articleId);
  //OpinionScreen _opinionScreen;
  @override
  State createState() => new ReplyTileState();
}

class ReplyTileState extends State<ReplyTile> {
 
  @override
  void initState() {
    super.initState();
    String url = baseUrl + "articles/" + widget.articleId + "/opinions/" + widget.opinionId;
    
  }

  @override
  Widget build(BuildContext context) {
    final opinions = Provider.of<Opinions>(context).opinions;
    //_key = new PageStorageKey('${widget.opinionId}');
    return new ExpansionTile(
      //key: _key,
      title: new Text("View Replies"),
      children: <Widget>[
        // new FutureBuilder(
        //   future: Provider.of<Opinions>.getAllReplies(widget.articleId,widget.opinionId),
        //   builder:
        //       (BuildContext context, AsyncSnapshot<http.Response> response) {
        //     if (!response.hasData) {
        //       return const Center(
        //         child: const Text('Loading...'),
        //       );
        //     } else if (response.data.statusCode != 200) {
        //       return const Center(
        //         child: const Text('Error loading data'),
        //       );
        //     } else {
        //       List<dynamic> responseJson = json.decode(response.data.body);
        //       List<Widget> replyList = [];
        //       responseJson.forEach((element) {
        //         replyList.add(new ListTile(
        //           dense: true,
        //           title: new Text(element['content']),
        //         ));
        //       });
        //       return new Column(children: replyList);
        //     }
        //   },
        // )
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: opinions.length,
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: opinions[index],
              child: ReplyCard(),
            ),
          )
      ],
    );
}
}