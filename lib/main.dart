import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var location = "";

  var lat = 39.0, lng = 36.0;
  List<Marker> markers = [];
  @override
  void initState() {
    // TODO: implement initState
    markers.add(Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(39.0, 40.0),
      builder: (ctx) => Container(
        child: Icon(Icons.location_on),
      ),
    ));
  }

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);
    location = "$position.latitude, $position.longitude";
    _controller.move(LatLng(position.latitude, position.longitude), 6);
    markers.add(Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(position.latitude, position.longitude),
      builder: (ctx) => Container(
        child: Icon(Icons.location_on),
      ),
    ));
    setState(() {});
  }

  MapController _controller = new MapController();
  double zoom = 6.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: FlutterMap(
                mapController: _controller,
                options: new MapOptions(
                  controller: _controller,
                  center: LatLng(lat, lng),
                  zoom: zoom,
                ),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: markers),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: TextButton(
                  child: Text("Güncel Konum"),
                  onPressed: () {
                    setState(() {
                      getCurrentLocation();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
