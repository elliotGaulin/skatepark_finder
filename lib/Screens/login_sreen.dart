import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ecran de connexion, redirige vers l'écran suivant si la connexion est réussie
class LoginScreen extends StatefulWidget {
  final Widget? nextScreen;

  const LoginScreen({required this.nextScreen, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _email = "";
  String? _password = "";

  @override
  Widget build(BuildContext context) {

    //Écoute pour des changements d'état de l'utilisateur
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        if (widget.nextScreen == null) {
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => widget.nextScreen!,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        RegExp emailRegExp =
                            RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (value == null ||
                            value.isEmpty ||
                            !emailRegExp.hasMatch(value)) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (newValue) => setState(() {
                            _email = newValue;
                          })),
                  TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (newValue) => setState(() {
                            _password = newValue;
                          })),
                ]),
              ),
              ElevatedButton(
                onPressed: () async {
                  debugPrint('Login');
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    debugPrint("$_email, $_password");
                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: _email!, password: _password!);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
