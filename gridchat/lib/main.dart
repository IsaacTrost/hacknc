import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import 'package:sticky_headers/sticky_headers.dart';

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
          toolbarHeight: 100,
          shape: Border(
              bottom: BorderSide(
                  color: Color.fromARGB(255, 151, 229, 201), width: 2)),
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

class Cell {
  double? latitude;
  double? longitude;
  Cell(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }
}

class _MapState extends State<Map> {
  Set<Polyline> gridLines = {};
  LocationData? _currentPosition;
  Location location = new Location();
  var _gridCellCenters = <Cell>[];
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _here;
  var page2 = Chat();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Image.network(
          // <-- SEE HERE
          'https://iili.io/msFVKG.md.png', height: 50,
        ),
        actions: [
          Container(
    margin: const EdgeInsets.only(right: 20.0),
    child : IconButton(
            onPressed: _pushBattery, icon: const Icon(Icons.battery_1_bar)),
          )
          ],

      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        polylines: gridLines,
        initialCameraPosition:
            _here ?? CameraPosition(target: LatLng(30.0, 30.0), zoom: .8),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          final GoogleMapController cntr = await _controller.future;
          _CreateSpoofGrid();
          location.onLocationChanged.listen((l) {
            _GetLocalGrid();
          });
        },
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pushChat,
        label: Text(
          'Chat with your grid',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.attach_email_outlined),
        backgroundColor: Color.fromARGB(255, 151, 229, 201),
        foregroundColor: Color.fromARGB(255, 43, 43, 43),
        extendedPadding: const EdgeInsets.all(75.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
    );
  }

  void _pushBattery() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Battery(), fullscreenDialog: false),
    );
  }
  void initState() {
    super.initState();
    fetchLocation();
  }

  void _pushChat() {
    print("asdf");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page2, fullscreenDialog: false),
    );
  }

  void _nothing() {}
  Future<void> _Go30() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(30, 30), zoom: 1)));
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12.742 * asin(sqrt(a));
  }

  void _GetLocalGrid() {
    final Set<Polyline> locGridLines = {};
    final convert = (1 / 111111) * 50;
    var counter = 0;
    for (var x in _gridCellCenters) {
      var lat = x.latitude ?? 20.0;
      var long = x.longitude ?? 20.0;
      var negx = lat - convert;
      var posx = lat + convert;
      var negy = long - convert;
      var posy = long + convert;
      List<LatLng> latlng = [
        LatLng(negx, negy),
        LatLng(posx, negy),
        LatLng(negx, posy),
        LatLng(posx, posy),
        LatLng(posx, negy),
        LatLng(posx, posy),
        LatLng(negx, negy),
        LatLng(negx, posy)
      ];
      for (var i = 0; i < 4; i++) {
        locGridLines.add(Polyline(
          polylineId: PolylineId((i + 4 * counter).toString()),
          visible: true,
          width: 1,
          points: latlng.sublist(i * 2, i * 2 + 2),
          color: Colors.red,
        ));
      }
      counter++;
    }
    setState(() {
      gridLines = locGridLines;
    });
  }

  _CreateSpoofGrid() {
    final convert = (1 / 111111);
    final offset = 5 * convert * 100;
    for (var i = 0; i < 100; i++) {
      _gridCellCenters.add(Cell(30 - offset + (i % 10) * convert * 100,
          30 - offset + (i ~/ 10) * convert * 100));
    }
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
    "Yo knkow, I really think I like cheese",
    "But I dont"
  ];
  final myController = TextEditingController();
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
        floatingActionButton: FloatingActionButton.extended(
          // When the user presses the button, show an alert dialog containing
          // the text that the user has entered into the text field.
          onPressed: () {
            if (Text(myController.text) != null) {
              _suggestions.insert(0, myController.text);
              myController.text = "";
              setState(() {
                _suggestions;
              });
            }
            ;
          },
          label: const Text('Send'),
          icon: const Icon(Icons.send_rounded),
          backgroundColor: Color.fromARGB(255, 151, 229, 201),
          foregroundColor: Color.fromARGB(255, 43, 43, 43),
        ),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        appBar: AppBar(
          automaticallyImplyLeading: false,
                    leading:           Container(
    margin: const EdgeInsets.only(left: 20.0),
    child : IconButton(
            onPressed: _BackMap, icon: const Icon(Icons.map_rounded)),
          ),
          title: Image.network(
            // <-- SEE HERE
            'https://iili.io/msFVKG.md.png', height: 50,
          ),
        ),
        body: CustomScrollView(
          reverse: true,
          slivers: [
            SliverPadding(
                padding: const EdgeInsets.only(
                    right: 140.0, top: 20.0, left: 20.0, bottom: 20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      TextField(
                        controller: myController,
                      ),
                    ],
                  ),
                )),
            SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index.isOdd) return const Divider();
                      index = index ~/ 2;
                      return Container(
                        height: 30,
                        child: Text(
                            ' ${now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString() + "      " + _suggestions[index]}',
                            style: TextStyle(
                                color: Color.fromARGB(255, 151, 229, 201))),
                      );
                    },
                    childCount: _suggestions.length * 2,
                  ),
                )),
          ],
        ));
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