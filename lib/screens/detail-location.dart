import 'dart:async';
import 'package:car_fixing_services/screens/menubox.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class detailLocation extends StatefulWidget {
  final indexType;
  const detailLocation(this.indexType, {Key? key}) : super(key: key);

  @override
  State<detailLocation> createState() => _detailLocationState();
}

class _detailLocationState extends State<detailLocation> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final Completer<GoogleMapController> _controller = Completer();
  late Position myPos;
  late LocationSettings locationSettings;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  String shop_name = "loading...";
  String status = "loading...";
  List<String> type = ["car", 'motorbike'];
  List<String> typeC = ["Car", 'Motorbike'];

  Future getCurrentLocation() async {
    myPos = await _determinePosition();
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      forceLocationManager: true,
    );
    final GoogleMapController controller = await _controller.future;
    final MarkerId markerId = MarkerId('1');
    var user_id = auth.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user_id)
        .get()
        .then((value) {
      if (value.exists) {
        var latitude = value["current_location"]["latitude"];
        var longitude = value["current_location"]["longitude"];

        controller
            .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));

        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(latitude, longitude),
        );
        setState(() {
          markers[markerId] = marker;
        });
      }
    });
  }

  Future getDetail() async {
    var user_id = auth.currentUser!.uid;
    var nameType = type[widget.indexType];

    await FirebaseFirestore.instance
        .collection("service")
        .doc(nameType)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          shop_name = value[user_id]["shop_name"];
          status = value[user_id]["status"];
        });
      }
    });
  }

  Future btnCancel() async {
    var user_id = auth.currentUser!.uid;
    var nameType = type[widget.indexType];

    await FirebaseFirestore.instance
        .collection("service")
        .doc(nameType)
        .update({"$user_id.status": "Cancel"})
        .then((value) => print("Status Updated"))
        .catchError((error) => print("Failed to update status: $error"));

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Do you want cancel current request?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await btnCancel();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("Location"),
          backgroundColor: const Color(0xFF2D4059),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false);
            },
            child: const Icon(Icons.arrow_back),
          )),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(14.0367, 100.7276),
                  zoom: 15,
                ),
                markers: Set<Marker>.of(markers.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MenuBox("Type", typeC[widget.indexType], Color(0xFFFFD460), 70),
            const SizedBox(
              height: 5,
            ),
            MenuBox("Shop name", shop_name, Color(0xFFFFD460), 70),
            const SizedBox(
              height: 5,
            ),
            MenuBox("Status", status, Color(0xFFFFD460), 70),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  _showMyDialog();
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFFEA5455)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied.');
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}
