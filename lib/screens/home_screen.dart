import 'dart:async';
import 'dart:math' as math; // Ensure you have this import

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:muslim_app_4/screens/location_screen.dart';
import 'package:muslim_app_4/screens/prayer_screen.dart';
import 'package:muslim_app_4/screens/quraan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Tracks selected tab index
  double? _qiblaDirection;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _calculateQiblaDirection();
    setData();
  }

  void setData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUsed", true);
  }

  Future<void> _calculateQiblaDirection() async {
    const double meccaLatitude = 21.4225;
    const double meccaLongitude = 39.8262;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lon = position.longitude;
      double qiblaDirection =
      _calculateBearing(lat, lon, meccaLatitude, meccaLongitude);
      setState(() {
        _qiblaDirection = qiblaDirection;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  double _calculateBearing(
      double lat1, double lon1, double lat2, double lon2) {
    double dLon = _toRadians(lon2 - lon1);
    double y = math.sin(dLon) * math.cos(_toRadians(lat2));
    double x = math.cos(_toRadians(lat1)) * math.sin(_toRadians(lat2)) -
        math.sin(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.cos(dLon);
    double bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double _toDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    HijriCalendar.setLocal('ar');
    var _hijri = HijriCalendar.now();
    var day = DateTime.now();
    var format = DateFormat('EEE, d MMM yyyy');
    var formatted = format.format(day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Muslim Locator"),
      ),
      body: Column(
        children: [
          // Header with Hijri date
          _buildHeader(_size, _hijri, formatted),

          // Loading state for location
          _loadingLocation
              ? const CircularProgressIndicator()
              : _qiblaDirection != null
              ? _buildCompass()
              : const Text("Error loading Qibla direction."),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.book, title: 'Quran'),
          TabItem(icon: Icons.access_time, title: 'Prayer Times'),
          TabItem(icon: Icons.location_on, title: 'Map'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _onTabTapped(index); // Navigate to the selected tab
        },
        backgroundColor: Colors.blue,
        activeColor: Colors.white,
      ),
    );
  }

  void _onTabTapped(int index) {
    // Use Get.toNamed to navigate to the appropriate screen
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/quran');
        break;
      case 2:
        Get.offNamed('/prayer');
        break;
      case 3:
        Get.offNamed('/map');
        break;
    }
  }

  Widget _buildHeader(Size _size, HijriCalendar _hijri, String formatted) {
    return Container(
      height: _size.height * 0.22,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/background_img.jpg'),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _hijri.hDay.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                TextSpan(
                  text: " ${_hijri.longMonthName} ",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${_hijri.hYear} AH',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Text(
            formatted,
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        double? direction = snapshot.data?.heading;
        if (direction == null) {
          return const Text("Device does not have sensors for compass.");
        }

        double adjustedDirection = (_qiblaDirection ?? 0) - direction;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 200,
            width: 200,
            child: Transform.rotate(
              angle: _toRadians(adjustedDirection),
              child: Image.asset('assets/compass.png'),
            ),
          ),
        );
      },
    );
  }
}
