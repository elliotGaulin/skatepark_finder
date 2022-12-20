import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ecran de détail d'un skatepark
class DetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const DetailScreen({Key? key, required this.doc}) : super(key: key);

  //Ouvre l'url dans le navigateur web
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['nom']),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
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
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
          ),
        ],
      ),
    );
  }
}
