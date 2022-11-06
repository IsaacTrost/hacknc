// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

class Message {
  String content;

  Message(this.content);
  Message.unnamed() : content = 'FUCK';
}

// #docregion MyApp
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
      home: Chat(),
    );
  }
  // #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class _ChatState extends State<Chat> {
  final _suggestions = <Message>[];
  final _saved = <Message>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  LocationData? _currentPosition;
  Location location = new Location();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _here;
  bool mapcompleted = false;

  // #enddocregion RWS-var

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NEW from here ...
      appBar: AppBar(
        title: const Text('HLLN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_alarm_outlined),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
            icon: const Icon(Icons.chair),
            onPressed: _pushMap,
            tooltip: 'Saved Suggestions',
          ),
        ],
      ),
      // #docregion itemBuilder
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return const Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(getMessages(10)); /*4*/
          }
          final alreadySaved = _saved.contains(_suggestions[index]);
          // #docregion listTile
          return ListTile(
              title: Text(
                _suggestions[index].content,
                style: _biggerFont,
              ),
              trailing: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
                semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
              ),
              onTap: () {
                setState(() {
                  if (alreadySaved) {
                    _saved.remove(_suggestions[index]);
                  } else {
                    _saved.add(_suggestions[index]);
                  }
                });
              });
          // #enddocregion listTile
        },
      ),
    );
    // #enddocregion itemBuilder
  }

  void initState() {
    super.initState();
    fetchLocation();
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

  getMessages(int x) {
    var returny = <Message>[];
    for (int i = 0; i < x; i++) {
      if (_currentPosition == null) {
        returny.add(Message("ASDF"));
      } else {
        returny.add(Message(_currentPosition?.latitude.toString() ?? "asdf"));
      }
    }
    return returny;
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.content,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  void _pushMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition:
                  _here ?? CameraPosition(target: LatLng(30, 30), zoom: 1),
              onMapCreated: (GoogleMapController controller) {
                if (!mapcompleted) {
                  _controller.complete(controller);
                  mapcompleted = true;
                } else {
                  _controller;
                }
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _Go30,
              label: Text('LLl'),
              icon: Icon(Icons.directions_boat),
            ),
          );
        },
      ),
    );
  }

  Future<void> _Go30() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(30, 30), zoom: 1)));
  }
  // #enddocregion RWS-build
  // #docregion RWS-var
}
// #enddocregion RWS-var

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}
