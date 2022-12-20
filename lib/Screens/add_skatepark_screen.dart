import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:skatepark_finder/Widgets/my_button.dart';

class AddSkateparkScreen extends StatefulWidget {
  final String title;
  final QueryDocumentSnapshot<Map<String, dynamic>>? skatepark;
  final Function callback;
  const AddSkateparkScreen({required this.title, required this.callback, this.skatepark, super.key});
  @override
  State<AddSkateparkScreen> createState() => _AddSkateparkScreenState();
}

class _AddSkateparkScreenState extends State<AddSkateparkScreen> {
  final _formKey = GlobalKey<FormState>();

  String? title = "";
  String? latitude = "";
  String? longitude = "";
  String? imageUrl = "";
  String? googleMapsUrl = "";
  String? description = "";
  double? rating;

  bool isNumeric(String? s){
    if(s == null){
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollable(
          viewportBuilder: (context, position) => SingleChildScrollView(
            child: Column(children: [
              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['nom'] : null,
                    decoration: const InputDecoration(
                      hintText: 'Nom du skatepark',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                    onSaved: (newValue) => title = newValue,
                  ),
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['position'].latitude.toString(): null,
                    decoration: const InputDecoration(
                      hintText: 'Latitude',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !isNumeric(value)) {
                        return 'Veuillez entrer une latitude';
                      }
                      return null;
                    },
                    onSaved: (newValue) => latitude = newValue,
                  ),
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['position'].longitude.toString(): null,
                    decoration: const InputDecoration(
                      hintText: 'Longitude',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !isNumeric(value)) {
                        return 'Veuillez entrer une longitude';
                      }
                      return null;
                    },
                    onSaved: (newValue) => longitude = newValue,
                  ),
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['imageUrl']: null,
                      decoration:
                          const InputDecoration(hintText: "Url de l'image"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une url';
                        }
                        return null;
                      },
                      onSaved: (newValue) => imageUrl = newValue,
                      ),
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['mapsUrl']: null,
                      decoration:
                          const InputDecoration(hintText: "Url de google maps"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une url';
                        }
                        return null;
                      },
                      onSaved: (newValue) => googleMapsUrl = newValue,
                      ),
                  TextFormField(
                    initialValue: widget.skatepark != null ? widget.skatepark!.data()['description']: "",
                      decoration:
                          const InputDecoration(hintText: "Description"),
                      minLines: 1,
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une url';
                        }
                        return null;
                      },
                      onSaved: (newValue) => description = newValue,
                      ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RatingBar.builder(
                      initialRating: widget.skatepark != null ? widget.skatepark!.data()['note'] : 0.0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          this.rating = rating;
                        });
                      },
                    ),
                  ),
                ]),
              ),
              MyButton(
                  text: widget.title,
                  onPressed: () {
                    debugPrint("Ajout d'un skatepark");
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      widget.callback({
                        "nom": title,
                        "imageUrl": imageUrl,
                        "mapsUrl": googleMapsUrl,
                        "description": description,
                        "note": rating ?? (widget.skatepark != null ? widget.skatepark!.data()['note'] : 0.0),
                        "position": GeoPoint(double.parse(latitude!), double.parse(longitude!))
                      });

                      debugPrint("Formulaire valide");
                      
                    }
                  })
            ]),
          ),
        ),
      ),
    );
  }
}
