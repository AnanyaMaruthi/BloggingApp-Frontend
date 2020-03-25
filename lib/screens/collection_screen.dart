import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// Widgets
import '../widgets/collection_details_card.dart';

// Providers
import '../providers/articles.dart';
import '../providers/collections.dart';
import '../providers/collection.dart';

class CollectionScreen extends StatefulWidget {
  static const routeName = "/collection";

  var collection_id;

  CollectionScreen(this.collection_id);

  @override
  _CollectionScreenState createState() => _CollectionScreenState(collection_id);
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  var collection_id;
  Collection collection;

  _CollectionScreenState(this.collection_id);

  @override
  void initState() {
    super.initState();
    print("Collection screen");
    print(this.collection_id);
  }

  @override
  void didChangeDependencies() {
    collection = Provider.of<Collections>(context).findById(collection_id);
    super.didChangeDependencies();
    print(collection.collection_name);
    // Provider.of<Collections>(context).getCollectionById()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collection Screen"),
      ),
      body: Column(
        children: [
          CollectionDetailsCard(collection: collection),
          Row(
            children: [Text("Article list ")],
          ),
        ],
      ),
      floatingActionButton: plusFloatingButton(),
    );
  }

  Widget plusFloatingButton() {
    return (SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(),
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => {},
      onClose: () => {},
      tooltip: 'Options',
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 10.0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.delete_sweep),
          backgroundColor: Colors.tealAccent,
          label: 'Delete Collection',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => {},
        ),
        SpeedDialChild(
          child: Icon(Icons.edit),
          backgroundColor: Colors.tealAccent,
          label: 'Edit Collection',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => {},
        ),
        SpeedDialChild(
          child: Icon(Icons.delete),
          backgroundColor: Colors.tealAccent,
          label: 'Delete Article',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => {},
        ),
        SpeedDialChild(
          child: Icon(Icons.person_add),
          backgroundColor: Colors.tealAccent,
          label: 'Add Author',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => {},
        ),
        SpeedDialChild(
            child: Icon(Icons.add),
            backgroundColor: Colors.tealAccent,
            label: 'Add Article',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => {}),
      ],
    ));
  }
}