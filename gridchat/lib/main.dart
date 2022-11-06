import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: Mapy(),
    );
  }
  // #enddocregion build
}

Future<http.Response> postUser(LatLng loc) {
  return http.post(
    Uri.parse('https://gridchat.tech/chat'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'latitude': loc.latitude.toString(),
      'longitude': loc.longitude.toString(),
    }),
  );
}

Future<http.Response> postMessage(Message message, int CurrentGridId) {
  return http.post(
    Uri.parse('https://gridchat.tech/chat'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user_id': "1",
      'grid_id': CurrentGridId.toString(),
      'content': message.content,
    }),
  );
}

Future<int> postHeartbeat(double latitude, double longitude, int userid) async {
  var response = await http.post(
    Uri.parse('https://gridchat.tech/heartbeat'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Keep-Alive': "timeout=5, max=1000"
    },
    body: jsonEncode(<String, String>{
      'user_id': userid.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    }),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> grideo = jsonDecode(response.body);

    return grideo["grid_id"];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load cells');
  }
}

// Future<Cell> fetchCells() async {
//   final response = await http
//       .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     return Cell.fromJson(jsonDecode(response.body));
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     throw Exception('Failed to load cells');
//   }
// }

Future<List<Message>> fetchMessages(int currentGridId) async {
  final queryParameters = {
    'grid_id': currentGridId,
  };
  final response = await http.get(Uri.parse('https://gridchat.tech/chat'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Message> returny = [];
    for (var i = 0; i < 100; i++) {
      print(jsonDecode(response.body));
    }
    var jsony = jsonDecode(response.body);
    for (var asdf in jsony) {
      returny.add(Message.fromJson(asdf));
    }
    return returny;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load cells');
  }
}

class Message {
  String content;
  DateTime time;
  Message({required this.content, required this.time});
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      time: DateTime.parse(json['time']),
    );
  }
}

class Cell {
  double latitude;
  double longitude;
  int activity;
  Cell(
      {required this.latitude,
      required this.longitude,
      required this.activity});
  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
        latitude: json['latitude'],
        longitude: json['longitude'],
        activity: json['activity']);
  }
  bool contained(LatLng loc) {
    final convert = (1 / 111111) * 50;
    if ((this.latitude + convert > loc.latitude) &&
        (this.latitude - convert < loc.latitude) &&
        (this.longitude + convert > loc.longitude) &&
        (this.longitude - convert < loc.longitude)) {
      return true;
    }
    return false;
  }
}

class _MapyState extends State<Mapy> {
  var userid = 1;
  Set<Polygon> gridLines = {};
  LocationData? _currentPosition;
  Location location = new Location();
  var _gridCellCenters = <Cell>[];
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _here;
  int currentGridId = 0;

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
            child: IconButton(
                onPressed: _pushBattery, icon: const Icon(Icons.battery_1_bar)),
          )
        ],
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.hybrid,
        polygons: gridLines,
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
      MaterialPageRoute(
          builder: (context) => Battery(), fullscreenDialog: false),
    );
  }

  void initState() {
    super.initState();
    fetchLocation();
  }

  void _pushChat() {
    print("asdf");
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12.742 * asin(sqrt(a));
  }

  void _GetLocalGrid() {
    final Set<Polygon> locGridLines = {};
    final convert = (1 / (111111)) * 50;
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
        LatLng(posx, posy),
        LatLng(negx, posy),
      ];
      locGridLines.add(Polygon(
        polygonId: PolygonId((counter).toString()),
        visible: true,
        fillColor: Color.fromARGB(8 * x.activity, 40, 151, 201),
        points: latlng,
        strokeWidth: 1,
        strokeColor: Color.fromARGB(255, 151, 229, 201),
      ));

      counter++;
    }

    setState(() {
      gridLines = locGridLines;
    });
  }

  _CreateSpoofGrid() {
    final convert = (1 / (111111));
    var rng = Random();
    final offset = 5 * convert * 100;
    for (var i = 0; i < 100; i++) {
      _gridCellCenters.add(Cell(
          latitude: 35.7796 - offset + (i % 10) * convert * 100,
          longitude: -78.6382 - offset + (i ~/ 10) * convert * 100,
          activity: rng.nextInt(32)));
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
    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (_currentPosition != null) {
        //currentGridId = await postHeartbeat(currentLocation.latitude ?? 30.0,
        //    currentLocation.longitude ?? 30.0, userid);
        setState(() {
          _currentPosition;
        });
        setState(() {
          _here = CameraPosition(
            target: LatLng(_currentPosition?.latitude ?? 1.0,
                _currentPosition?.longitude ?? 1.0),
            zoom: 14.4746,
          );
        });
      }
    });
  }
}

class Mapy extends StatefulWidget {
  const Mapy({super.key});

  @override
  State<Mapy> createState() => _MapyState();
}

class _ChatState extends State<Chat> {
  var userid = 1;
  var currentGridId = 0;
  List<Message> _suggestions = [
    Message(
        content:
            "I really feel like this building could use less lead in its water",
        time: DateTime.now().subtract(new Duration(days: 1))),
    Message(
        content:
            "I agree, there is only so much  lead a student should be reasonably expected to consume.",
        time: DateTime.now().subtract(new Duration(hours: 18))),
    Message(
        content:
            "I actually really enjoy the taste of lead, so I dont get what the fuss is about.",
        time: DateTime.now().subtract(new Duration(hours: 15))),
    Message(
        content: "Not to get off topic, but I really like pizza",
        time: DateTime.now().subtract(new Duration(hours: 10))),
    Message(
        content: "I agree about the pizza",
        time: DateTime.now().subtract(new Duration(hours: 5))),
    Message(
        content: "Lead on pizza is really the moves",
        time: DateTime.now().subtract(new Duration(days: 5))),
    Message(
        content: "That has to be even worse then the pineapple craze",
        time: DateTime.now().subtract(new Duration(minutes: 45))),
    Message(
        content: "How about that math test, that was brutal",
        time: DateTime.now().subtract(new Duration(minutes: 12))),
    Message(
        content: "Nobody comes on here to talk about school, man",
        time: DateTime.now().subtract(new Duration(minutes: 11))),
  ];
  final myController = TextEditingController();
  final _saved = <Text>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  LocationData? _currentPosition;
  Location location = new Location();
  final DateFormat formatter = DateFormat('h:mm  M/d ');

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
              postMessage(
                  Message(content: myController.text, time: DateTime.now()),
                  currentGridId);
              _suggestions.insert(
                  0, Message(content: myController.text, time: DateTime.now()));
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
          leading: Container(
            margin: const EdgeInsets.only(left: 20.0),
            child: IconButton(
                onPressed: _BackMap, icon: const Icon(Icons.map_rounded)),
          ),
          title: Image.network(
            // <-- SEE HERE
            'https://iili.io/msFVKG.md.png', height: 50,
          ),
        ),
        // #docregion itemBuilder
        // body: ListView(
        //   children: [
        //     StickyHeader(
        //         header: Padding(
        //           padding: const EdgeInsets.all(16.0),
        //           child: TextField(
        //             controller: myController,
        //           ),
        //         ),
        //         content: ListView.builder(
        //             padding: const EdgeInsets.all(16.0),
        //             itemCount: _suggestions.length,
        //             itemBuilder: (BuildContext context, int index) {
        //               return Container(
        //                 height: 50,
        //                 child: Center(child: Text('Test ${_suggestions[index]}')),
        //               );
        //             })),
        //   ],
        // ),

        body: CustomScrollView(
          reverse: true,
          slivers: [
            SliverPadding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 20,
                  right: 150,
                  bottom: 15,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      TextField(
                        controller: myController,
                        decoration: InputDecoration(
                          hintText: "Type here...",
                          contentPadding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),

                          filled: true, //<-- SEE HERE
                          fillColor: Colors.white, //<-- SEE HERE
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 3,
                                color: Color.fromARGB(
                                    255, 151, 229, 201)), //<-- SEE HERE
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
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
                      return ListTile(
                          title: Text(' ${_suggestions[index].content}',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 151, 229, 201))),
                          trailing: Text(
                              formatter.format(_suggestions[index].time),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 151, 229, 201))));
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

  loadMessages() async {
    _suggestions = await fetchMessages(currentGridId);
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
    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (_currentPosition != null) {
        //currentGridId = await postHeartbeat(currentLocation.latitude ?? 30.0,
        //    currentLocation.longitude ?? 30.0, userid);
        setState(() {
          _currentPosition;
        });
      }
    });
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

class _BatteryState extends State<Battery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Container(
            margin: const EdgeInsets.only(left: 20.0),
            child: IconButton(
                onPressed: _BackMap, icon: const Icon(Icons.map_rounded)),
          ),
          title: Text("Is my phone dead?"),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                  onPressed: _pushClock, icon: const Icon(Icons.alarm)),
            ),
          ],
        ),
        body: Text("No. Your phone is not dead."));
    // #enddocregion itemBuilder
  }

  void _BackMap() {
    Navigator.pop(context);
  }

  void _pushClock() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Clock(), fullscreenDialog: false),
    );
  }
  // #enddocregion RWS-build
  // #docregion RWS-var
}
// #enddocregion RWS-var

class Battery extends StatefulWidget {
  const Battery({super.key});

  @override
  State<Battery> createState() => _BatteryState();
}

class _ClockState extends State<Clock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Container(
            margin: const EdgeInsets.only(left: 20.0),
            child: IconButton(
                onPressed: _BackMap, icon: const Icon(Icons.battery_1_bar)),
          ),
          title: Text("What time is it?"),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                  onPressed: _popClock, icon: const Icon(Icons.map_rounded)),
            ),
          ],
        ),
        body: Image.network(
          // <-- SEE HERE
          'https://media.giphy.com/avatars/Bojangles1977/mQphNcfEoEmA.gif',
          width: 10000,
        ));
    // #enddocregion itemBuilder
  }

  void _BackMap() {
    Navigator.pop(context);
  }

  void _pushClock() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Clock(), fullscreenDialog: false),
    );
  }

  void _popClock() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
  // #enddocregion RWS-build
  // #docregion RWS-var
}
// #enddocregion RWS-var

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}
