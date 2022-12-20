import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skatepark_finder/Widgets/skatepark_list_item.dart';

/// La page de la liste des skatepark
class ListSkateparkScreen extends StatefulWidget {
  const ListSkateparkScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ListSkateparkScreenState createState() => _ListSkateparkScreenState();
}

class _ListSkateparkScreenState extends State<ListSkateparkScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('skatepark')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
          setState(() {
            _docs = querySnapshot.docs;
          });
    });
    super.initState();
  }

  @override
  void setState(fn) {
    super.setState(fn);
    FirebaseFirestore.instance
        .collection('skatepark')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
          setState(() {
            _docs = querySnapshot.docs;
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
        itemCount: _docs.length,
        itemBuilder: (context, index) => SkateparkListItem(
          skatepark: _docs.elementAt(index),
          color: index % 2 == 0 ? Colors.grey[300]! : Colors.grey[200]!,
          delete: () async {
            await FirebaseFirestore.instance
                .collection('skatepark')
                .doc(_docs.elementAt(index).id)
                .delete();
            setState(() {
              _docs.removeAt(index);
            });
          },
          update: (Map<String, dynamic> skateparkData) async {
            debugPrint('update');
            await FirebaseFirestore.instance
                .collection('skatepark')
                .doc(_docs.elementAt(index).id)
                .update(skateparkData);
            setState(() {});
            if(Navigator.canPop(context)){
              Navigator.pop(context);
            }
          }
        ),
      )),
    );
  }
}
