import 'package:app/screens/voice_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:app/utils/device_button.dart';

class ManualControl extends StatefulWidget {
  const ManualControl({super.key});

  @override
  State<ManualControl> createState() => _ManualControlState();
}

class _ManualControlState extends State<ManualControl> {
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List smartDevices = [
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.white),
      "Light 1",
      "Living Room",
      false,
    ],
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.white),
      "Light 2",
      "Floor 1",
      false,
    ],
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.white),
      "Light 3",
      "Toilet",
      false,
    ],
    [
      const Icon(LineIcons.lightbulb, size: 35, color: Colors.white),
      "Light 4",
      "Kitchen",
      false,
    ]
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < smartDevices.length; i++) {
      _dbRef.child('light${i + 1}/turn').onValue.listen((event) {
        final bool newValue = event.snapshot.value == "1";
        setState(() {
          smartDevices[i][3] = newValue;
          smartDevices[i][0] = newValue
              ? const Icon(LineIcons.lightbulbAlt,
                  size: 35, color: Colors.yellow)
              : const Icon(LineIcons.lightbulb, size: 35, color: Colors.white);
        });
      });
    }
  }

  void powerChange(bool value, int index) {
    _dbRef.child('light${index + 1}/turn').set(value ? "1" : "0");
    setState(() {
      smartDevices[index][3] = value;
      smartDevices[index][0] = value
          ? const Icon(LineIcons.lightbulbAlt, size: 35, color: Colors.yellow)
          : const Icon(LineIcons.lightbulb, size: 35, color: Colors.white);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceControl(),
                  ),
                )
              },
              shape: const CircleBorder(),
              child: const Icon(LineIcons.microphone),
            ),
            backgroundColor: Colors.black,
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GradientText(
                      'Home Control',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                      colors: const [
                        Colors.deepPurpleAccent,
                        Colors.deepPurple,
                        Colors.purple,
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Devices',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70),
                      ),
                    ]),
              ),
              Expanded(
                child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                    itemCount: smartDevices.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return DeviceButton(
                        icon: smartDevices[index][0],
                        name: smartDevices[index][1],
                        area: smartDevices[index][2],
                        power: smartDevices[index][3],
                        onChange: (value) {
                          powerChange(value, index);
                        },
                      );
                    }),
              ),
            ])));
  }
}
