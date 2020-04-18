import '../widgets/opinion_preview_card.dart';

import '../providers/opinions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';


class OpinionSystem extends StatefulWidget {

  String articleId;
  OpinionSystem(@required this.articleId);

  @override
  _OpinionSystemState createState() => _OpinionSystemState();
}

class _OpinionSystemState extends State<OpinionSystem> {

  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final opinionsData = Provider.of<Opinions>(context);
    final opinions = opinionsData.opinions;
    return Card(
      child: Column(
        children: <Widget>[
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: TextFormField(
              controller : _commentController,
              decoration: InputDecoration(
                  labelText: "Leave your opinion",
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _insertOpinion,
                  )),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Text(
                opinions.length.toString() + " Comments",
              ),
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: opinions.length,
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: opinions[index],
              child: OpinionPreviewCard(),
            ),
          )
        ],
      ),
    );
  }

  void _insertOpinion(){
    print("lol");
    String content = _commentController.text;
    Provider.of<Opinions>(context).addOpinion(content, widget.articleId).then((_){
      //Remove it later. The new opinion should be dsiaplyed on the list
      Toast.show("New opinion added!", context,
            duration: 7, gravity: Toast.BOTTOM);
    });
  }
}
