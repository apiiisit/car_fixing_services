import 'dart:io';

import 'package:car_fixing_services/api/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:car_fixing_services/util/showDialog.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();

  bool checkUser = false;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  File? file;
  String urlAvatar =
      "https://firebasestorage.googleapis.com/v0/b/car-fixing-services.appspot.com/o/avatar%2FNone%2Favatar.png?alt=media&token=e375d5b3-3a98-4f32-9bd6-607790071e36";
  UploadTask? task;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Update your profile?'),
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
                checkUser ? await updateProfile() : await addProfile();

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Home()),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProfile() async {
    var user_id = auth.currentUser!.uid;

    return users
        .doc(user_id)
        .update({
          "profile": {
            "avatar": urlAvatar,
            "fname": fnameController.text,
            "lname": lnameController.text
          }
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> addProfile() async {
    var user_id = auth.currentUser!.uid;

    return users
        .doc(user_id)
        .set({
          "profile": {
            "avatar": urlAvatar,
            "fname": fnameController.text,
            "lname": lnameController.text
          }
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  void getProfile() async {
    var user_id = auth.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user_id)
        .get()
        .then((value) {
      if (value.exists) {
        var fname = value["profile"]["fname"];
        var lname = value["profile"]["lname"];
        var avatar = value["profile"]["avatar"];
        setState(() {
          fnameController.text = fname;
          lnameController.text = lname;
          urlAvatar = avatar;
          checkUser = true;
        });
      }
    });
  }

  void confirmUpdate() {
    if (fnameController.text.isEmpty || lnameController.text.isEmpty) {
      showMyDialog(context, "Edit profile", "Please complete the information.");
    } else {
      _showMyDialog();
    }
  }

  Future selectFile() async {
    print("select file");
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path;

    setState(() => file = File(path!));
    print("file path");
    print(file);

    uploadFile();
  }

  void uploadFile() async {
    var user_id = auth.currentUser!.uid;

    if (file == null) return;
    final fileName = file?.path.split('/').last;
    final destination = 'avatar/$user_id/$fileName';

    task = FirebaseAPI.uploadFile(destination, file!);

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    setState(() {
      urlAvatar = url;
    });

    print(urlAvatar);
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 32,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(75, 0, 0, 0),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    urlAvatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              TextButton(
                onPressed: selectFile,
                child: const Text(
                  "Edit image",
                  style: TextStyle(
                      color: Color(0xFF2D4059),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: fnameController,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: "Name",
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextFormField(
                      controller: lnameController,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: "Lastname",
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          confirmUpdate();
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFFF07B3F)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
