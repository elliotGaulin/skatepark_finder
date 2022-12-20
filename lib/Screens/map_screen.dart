import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skatepark_finder/Screens/add_skatepark_screen.dart';
import 'package:skatepark_finder/Screens/login_sreen.dart';
import '../Widgets/marker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map/map.dart' as map;
import 'package:latlng/latlng.dart';
import 'list_skatepark_screen.dart';

/// La page de la carte, écran principal de l'application
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});

  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _currentPosition = const LatLng(46.05876088016983, -71.94626299551419); // Par défaut, victoriaville
  bool _loggedIn = false;

  map.MapController controller = map.MapController(
      location: const LatLng(46.05876088016983, -71.94626299551419)); // Par défaut, victoriaville
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];

  //override de initstate pour recuperer la position de l'utilisateur et la liste des skatepark
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('skatepark')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      setState(() {
        _docs = querySnapshot.docs;
      });
    });

    Geolocator.getCurrentPosition().then((Position position) {
      print(position);
      _currentPosition = LatLng(position.latitude, position.longitude);
      controller.center = LatLng(position.latitude, position.longitude);
      setState(() {});
    });
  }

  //override de setstate pour mettre a jour la liste des skatepark
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

  //replace le centre de la carte sur la position de l'utilisateur
  void _gotoDefault() {
    controller.center = _currentPosition;
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;

  //démarre gestion du zoom et du drag
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
    setState(() {});
  }

  //gestion du zoom et du drag
  void _onScaleUpdate(
      ScaleUpdateDetails details, map.MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  //construit les markers sur la carte
  Widget _buildMarker(Offset pos, Color color, doc) {
    return Marker(pos: pos, color: color, doc: doc);
  }

  //Obtiens l'url de l'image de la carte google selon les coordonnées
  String google(int z, int x, int y) {
    //Google Maps
    final url =
        'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

    return url;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _loggedIn = user != null;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          //bouton pour ajouter un skatepark
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              User? user = await FirebaseAuth.instance.currentUser;
              callback(Map<String, dynamic> skatepark) {
                FirebaseFirestore.instance
                    .collection("skatepark")
                    .add(skatepark);
                setState(() {});
                if(Navigator.canPop(context))
                  Navigator.pop(context);
              }

              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddSkateparkScreen(
                          title: "Ajouter un skatepark",
                          callback: callback,
                        )));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LoginScreen(
                          nextScreen: AddSkateparkScreen(
                            title: "Ajouter un skatepark",
                            callback: callback,
                          ),
                        )));
              }
            },
          ),
          //bouton pour afficher la liste des skatepark
          IconButton(
              icon: const Icon(Icons.list),
              onPressed: () async {
                User? user = await FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ListSkateparkScreen(
                            title: "Liste des skateparks",
                          )));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginScreen(
                            nextScreen: ListSkateparkScreen(
                                title: "Liste des skateparks"),
                          )));
                }
              }),
          //bouton pour se connecter ou se déconnecter
          IconButton(
            icon:
                _loggedIn ? const Icon(Icons.logout) : const Icon(Icons.login),
            onPressed: () async {
              if (_loggedIn) {
                await FirebaseAuth.instance.signOut();
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginScreen(
                          nextScreen: null,
                        )));
              }
            },
          ),
        ],
      ),
      body: map.MapLayout(
        controller: controller,
        builder: (context, transformer) {

          //contruction des markers
          final markerWidgets = [];
          for (var doc in _docs) {
            GeoPoint position = doc['position'];
            LatLng latLng = LatLng(position.latitude, position.longitude);
            markerWidgets.add(
                _buildMarker(transformer.toOffset(latLng), Colors.red, doc));
          }

          //detecte le zoom et le drag
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _onScaleStart,
            onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta.dy / -1000.0;
                  final zoom = clampDouble(controller.zoom + delta, 2, 18);

                  transformer.setZoomInPlace(zoom, event.localPosition);
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  //affiche la carte google
                  map.TileLayer(
                    builder: (context, x, y, z) {
                      final tilesInZoom = pow(2.0, z).floor();

                      while (x < 0) {
                        x += tilesInZoom;
                      }
                      while (y < 0) {
                        y += tilesInZoom;
                      }

                      x %= tilesInZoom;
                      y %= tilesInZoom;

                      return CachedNetworkImage(
                        imageUrl: google(z, x, y),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  //affiche les markers
                  ...markerWidgets
                ],
              ),
            ),
          );
        },
      ),
      //bouton pour se positionner sur la carte
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _gotoDefault();
        },
        tooltip: 'Ma position',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
