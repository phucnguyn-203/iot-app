import 'package:app/screens/voice_control.dart';
import 'package:flutter/material.dart';

//Navigation Bar package
import 'package:google_nav_bar/google_nav_bar.dart';

//Screens
// import 'package:iot/screens/home.dart';
import 'package:app/screens/manual_control.dart';
// import 'package:iot/screens/settings.dart';

//icons
import 'package:line_icons/line_icons.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoiceControl(),
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(LineIcons.microphone),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        color: Colors.black,
        child: GNav(
          backgroundColor: Colors.black,
          rippleColor: Colors.grey.shade900,
          tabBackgroundColor: Colors.grey.shade900,
          hoverColor: Colors.grey.shade900,
          activeColor: Colors.white,
          color: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(milliseconds: 400),
          gap: 4,
          iconSize: 30,
          onTabChange: (selctedIndex) {
            setState(() {
              index = selctedIndex;
            });
          },
          selectedIndex: index,
          tabs: const [
            GButton(
              icon: LineIcons.home,
              text: "Home",
              iconSize: 22,
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            GButton(
              icon: LineIcons.podcast,
              text: "Devices",
              iconSize: 22,
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
            GButton(
              icon: LineIcons.cog,
              text: "Settings",
              iconSize: 22,
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: getSelectedWidget(index: index),
      ),
    );
  }

  Widget getSelectedWidget({required int index}) {
    // Widget widget;
    // switch (index) {
    //   case 0:
    //     // widget = const Home();
    //     break;
    //   case 1:
    //     widget = const Control();
    //     break;
    //   case 2:
    //     // widget = const Settings();
    //     break;
    //   default:
    //     widget = const Control();
    //     break;
    // }
    return const ManualControl();
  }
}
