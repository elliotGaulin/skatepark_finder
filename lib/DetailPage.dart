import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const DetailPage({Key? key, required this.doc}) : super(key: key);
  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['nom']),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              _launchUrl(Uri.parse(doc['mapsUrl']));
            },
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(doc['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text(
            "Description :",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(doc['description'], style: const TextStyle(fontSize: 18)),
          ),
          Center(
            child: RatingBar.builder(
              initialRating: doc['note'],
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          ),
        ],
      ),
    );
  }
}
