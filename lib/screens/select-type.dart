import 'package:car_fixing_services/screens/location.dart';
import 'package:flutter/material.dart';

import '../util/showDialog.dart';

class SelectType extends StatefulWidget {
  const SelectType({Key? key}) : super(key: key);

  @override
  State<SelectType> createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  List<String> items = ["Select", "Car", "Motorbike"];
  String selectedItem = "Select";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Vehicle type"),
        backgroundColor: const Color(0xFF2D4059),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D4059), width: 2)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedItem,
                iconSize: 0.0,
                isExpanded: true,
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D4059)),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedItem = value!),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                final indexType = items.indexOf(selectedItem);
                if (indexType == 0) {
                  showMyDialog(
                      context, "Select type", "Please select your type.");
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => Location(indexType - 1)),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFF07B3F)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
