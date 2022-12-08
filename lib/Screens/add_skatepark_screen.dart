import 'package:flutter/material.dart';

class AddSkateparkScreen extends StatelessWidget {
  const AddSkateparkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un skatepark'),
      ),
      body: const Center(
        child: Text('Ajouter un skatepark'),
      ),
    );
  }

}