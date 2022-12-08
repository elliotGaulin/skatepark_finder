import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skatepark_finder/Screens/detail_screen.dart';

class Marker extends StatelessWidget{
  final Offset pos;
  final Color color;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const Marker({Key? key, required this.pos, required this.color,required this.doc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        child: Icon(
          Icons.location_on,
          color: color,
          size: 48,
        ),
        onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailScreen(doc: doc)));
        },
      ),
    );
  }
}
