import 'dart:async';
import 'package:car_fixing_services/screens/detail-location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Location extends StatefulWidget {
  final indexType;

  const Location(this.indexType, {Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  Completer<GoogleMapController> _controller = Completer();
  late Position myPos;
  late LocationSettings locationSettings;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> setPos() async {
    myPos = await _determinePosition();
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      forceLocationManager: true,
    );

    final GoogleMapController controller = await _controller.future;

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Share your location?'),
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
                await postData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future postData() async {
    var user_id = auth.currentUser!.uid;
    CollectionReference service =
        FirebaseFirestore.instance.collection('service');
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    var location = await Geolocator.getCurrentPosition();

    var position = {
      "latitude": location.latitude,
      "longitude": location.longitude
    };

    List<String> type = ["car", "motorbike"];

    await service
        .doc(type[widget.indexType])
        .update({
          user_id: {
            "status": "Requesting",
            "shop_name": "Requesting",
            "location": position,
            "tel_user":
                auth.currentUser?.phoneNumber.toString().replaceAll('+66', '0'),
            "tel_shop": ""
          }
        })
        .then((value) => print("service Added"))
        .catchError((error) => print("Failed to add user: $error"));

    await users.doc(user_id).update({
      "log_location": FieldValue.arrayUnion([position]),
      "current_location": position
    }).then((value) async {
      print("location Added");
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => detailLocation(widget.indexType)),
      );
    }).catchError((error) => print("Failed to add user: $error"));
  }

  @override
  void initState() {
    setPos();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Location"),
        backgroundColor: const Color(0xFF2D4059),
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: const CameraPosition(
          target: LatLng(14.0367, 100.7276),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print(widget.indexType);
          _showMyDialog();
        },
        icon: const Icon(Icons.location_on),
        label: const Text("Share location"),
        backgroundColor: const Color(0xFF2D4059),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
  print('Return position');
  return await Geolocator.getCurrentPosition();
}
