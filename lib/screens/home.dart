import 'package:car_fixing_services/screens/detail-location.dart';
import 'package:car_fixing_services/screens/menubox-icon.dart';
import 'package:car_fixing_services/screens/select-type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_fixing_services/screens/profile.dart';
import 'package:car_fixing_services/screens/welcome.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String name = "loading...";
  String phone = "loading...";
  String urlAvatar =
      "https://firebasestorage.googleapis.com/v0/b/car-fixing-services.appspot.com/o/avatar%2FNone%2Favatar.png?alt=media&token=e375d5b3-3a98-4f32-9bd6-607790071e36";

  void getProfile() async {
    var user_id = auth.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user_id)
        .get()
        .then((value) {
      var fullname =
          value["profile"]["fname"] + " " + value["profile"]["lname"];
      var url = value["profile"]["avatar"];
      print(fullname);
      setState(() {
        name = fullname;
        urlAvatar = url;
      });
    }).catchError((e) {
      print(e.toString());
      setState(() {
        name = "No data";
      });
    });

    var user = auth.currentUser?.phoneNumber;
    user = user?.replaceAll("+66", "0");
    setState(() {
      phone = user!;
    });
  }

  Future selectPage() async {
    var user_id = auth.currentUser!.uid;
    bool? userInCar;
    bool? userInMotorbike;
    var indexType;

    await FirebaseFirestore.instance
        .collection("service")
        .doc("car")
        .get()
        .then((value) {
      bool? check = value.data()?.keys.contains(user_id);
      if (check!) {
        userInCar = (value[user_id]["status"] == "Finished" ||
                value[user_id]["status"] == "Cancel")
            ? false
            : true;
      } else {
        userInCar = false;
      }
    });
    await FirebaseFirestore.instance
        .collection("service")
        .doc("motorbike")
        .get()
        .then((value) {
      bool? check = value.data()?.keys.contains(user_id);
      if (check!) {
        userInMotorbike = (value[user_id]["status"] == "Finished" ||
                value[user_id]["status"] == "Cancel")
            ? false
            : true;
      } else {
        userInMotorbike = false;
      }
    });

    if (userInCar!) indexType = 0;
    if (userInMotorbike!) indexType = 1;

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => (userInCar! || userInMotorbike!)
            ? detailLocation(indexType)
            : const SelectType()));
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Car Services"),
          backgroundColor: const Color(0xFF2D4059),
        ),
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF2D4059),
                ),
                accountName: Text(name, style: const TextStyle(fontSize: 20)),
                accountEmail: Text(phone),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  backgroundImage: NetworkImage(urlAvatar),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Profile()),
                  );
                },
                title: const Text(
                  "Edit profile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              const Divider(),
              ListTile(
                onTap: () async {
                  await auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Welcome()),
                      (route) => false);
                },
                title: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  selectPage();
                },
                child: MenuBoxIcon("Request mechanic", "assets/images/car.png",
                    const Color(0xFFEA5455), 150),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ));
  }
}
