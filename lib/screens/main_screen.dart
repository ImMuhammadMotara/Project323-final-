import 'package:adhan/adhan.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:muslim_app_4/constants/constants.dart';
import 'package:muslim_app_4/screens/Location_screen.dart';
import 'package:muslim_app_4/screens/home_screen.dart';
import 'package:muslim_app_4/screens/prayer_screen.dart';
import 'package:muslim_app_4/screens/quraan_screen.dart'; // Ensure this import is correct

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectindex = 0;
  // Ensure widgets are properly defined
  List<Widget> _widgetList = [
    HomeScreen(),
    QuraanScreen(),
    PrayerScreen(),
    LocationScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _widgetList[selectindex],  // Display the selected screen
        bottomNavigationBar: ConvexAppBar(
          items: [
            TabItem(icon: Icons.home, title: 'Home'),     // Index 0
            TabItem(icon: Icons.book, title: 'Quran'),    // Index 1
            TabItem(icon: Icons.access_time, title: 'Prayer Times'), // Index 2
            TabItem(icon: Icons.location_on, title: 'Map'), // Index 3
          ],
          initialActiveIndex: 0,
          onTap: updateIndex,
          backgroundColor: Constants.kPrimary, // Ensure Constants.kPrimary is defined correctly
          activeColor: Colors.white, // Set active color
        ),
      ),
    );
  }

  // Update the selected index when a tab is pressed
  void updateIndex(int index) {
    setState(() {
      selectindex = index;
    });
  }
}
