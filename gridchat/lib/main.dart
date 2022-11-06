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
          shape: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 151, 229, 201),
            width: 2
          )
        ),
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
        ],
        
        toolbarHeight: 100,
        shape: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 151, 229, 201),
            width: 2
          )
        ),

        
      ),
      body: 
      GoogleMap(
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
        onPressed: _pushChat,
        label: Text('Chat with your grid', style: TextStyle(fontWeight: FontWeight.bold),),
        icon: Icon(Icons.attach_email_outlined),
        backgroundColor: Color.fromARGB(255, 151, 229, 201),
        foregroundColor: Color.fromARGB(255, 43, 43, 43),
        extendedPadding: const EdgeInsets.all(75.0),
      
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
      

    );
  }

  void initState() {
    super.initState();
    fetchLocation();
  }

  void _pushChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Chat(), fullscreenDialog: false),
    );
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

class _ChatState extends State<Chat> {
  final List<String> _suggestions = <String>[
    "asdfay a ",
    "a'lf yawom fha9isuf"
  ];
  final _saved = <Text>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  LocationData? _currentPosition;
  Location location = new Location();

  // #enddocregion RWS-var

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      // NEW from here ...
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          _suggestions.length++;
            _suggestions.add(myController.text);
        },
        child: const Icon(Icons.send),
        backgroundColor: Color.fromARGB(255, 151, 229, 201),
        foregroundColor: Color.fromARGB(255, 43, 43, 43),
      ),
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
      appBar: AppBar(
        title: Image.network(
          
          // <-- SEE HERE
          'https://iili.io/msFVKG.md.png', height: 50,
        ),
      ),
      // #docregion itemBuilder
      body: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: _suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              
              height: 30,
              
              child: Text(' ${now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString() + "      " + _suggestions[index]}', style: TextStyle(color: Color.fromARGB(255, 151, 229, 201))),
            );
          }),
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
    location.onLocationChanged.listen((LocationData currentLocation) {});
  }
  // #enddocregion RWS-build
  // #docregion RWS-var

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.5
    myController.dispose();
    super.dispose();
  }

  void _BackMap() {
    Navigator.pop(context);
  }

  void _Refreash() {}
}
// #enddocregion RWS-var

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}
