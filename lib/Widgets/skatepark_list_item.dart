import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Screens/add_skatepark_screen.dart';

/// Un item de la liste des skatepark
class SkateparkListItem extends StatelessWidget {
  final Color color;
  final QueryDocumentSnapshot<Map<String, dynamic>> skatepark;
  final Function delete;
  final Function update;
  const SkateparkListItem({required this.color, required this.skatepark, required this.delete, required this.update, Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: color,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Text(skatepark.data()['nom']),
          ),
          //bouton pour modifier un skatepark
          IconButton(onPressed: () async  {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddSkateparkScreen(
                    title: "Modifier un skatepark",
                    skatepark: skatepark,
                    callback: update,
                  ),
                ),
              );
              await update();
            }, 
            icon: const Icon(Icons.edit)
          ),
          //bouton pour supprimer un skatepark
          IconButton(
            onPressed: () async {
              delete();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
