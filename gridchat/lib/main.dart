import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

//import 'location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HLLN',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 43, 43, 43),
          foregroundColor: Color.fromARGB(255, 151, 229, 201),
        ),
      ),
      home: Map(),
    );
  }
  // #enddocregion build
}

class Message {
  String content;

  Message(this.content);
  Message.unnamed() : content = 'FUCK';
}

class _MapState extends State<Map> {
  final _suggestions = <Message>[];
  final _saved = <Message>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  LocationData? _currentPosition;
  Location location = new Location();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _here;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLLN'),
        actions: [
          IconButton(onPressed: _nothing, icon: const Icon(Icons.map_rounded)),
          IconButton(onPressed: _pushChat, icon: const Icon(Icons.chat_bubble)),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition:
            _here ?? CameraPosition(target: LatLng(30.0, 30.0), zoom: 1),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          final GoogleMapController cntr = await _controller.future;
          location.onLocationChanged.listen((l) {
            cntr.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(l.latitude ?? 30.0, l.longitude ?? 30.0),
                    zoom: 15),
              ),
            );
          });
        },
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _Go30,
        label: Text('LLl'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  void initState() {
    super.initState();
    fetchLocation();
  }

  void _pushChat() {
    Navigator.of(context).push(
    )
  }
  void _nothing() {}
  Future<void> _Go30() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(30, 30), zoom: 1)));
  }


  fetchLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    if (_currentPosition != null) {
      _here = CameraPosition(
        target: LatLng(_currentPosition?.latitude ?? 1.0,
            _currentPosition?.longitude ?? 1.0),
        zoom: 14.4746,
      );
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (_currentPosition != null) {
        _here = CameraPosition(
          target: LatLng(_currentPosition?.latitude ?? 1.0,
              _currentPosition?.longitude ?? 1.0),
          zoom: 14.4746,
        );
      }
    });
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}
