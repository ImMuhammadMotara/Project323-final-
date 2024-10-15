import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:adhan/adhan.dart';
import 'package:location/location.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({Key? key}) : super(key: key);

  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Location location = Location();
  LocationData? _currentPosition;
  double? latitude, longitude;
  bool locationFetched = false; // Track whether the location has been fetched
  bool isHanafi = true; // Track whether Hanafi or Shafi is selected (default Hanafi)
  int _selectedIndex = 1; // Default index for Prayer Times tab

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Prayer Timings',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: locationFetched // Check if location has been fetched
            ? Column(
          children: [
            // Switch to toggle between Hanafi and Shafi
            SwitchListTile(
              title: Text(isHanafi ? 'Hanafi' : 'Shafi'),
              value: isHanafi,
              onChanged: (bool value) {
                setState(() {
                  isHanafi = value; // Update the madhab when the switch is toggled
                });
              },
              secondary: const Icon(Icons.swap_horiz), // Icon for switching
            ),
            Expanded(child: buildPrayerTimesUI()), // Show prayer times
          ],
        )
            : FutureBuilder(
          future: getLoc(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue, // Adjust as needed
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (_currentPosition == null) {
              return Center(
                child: Text('Location not available'),
              );
            }

            return Container(); // If location is fetched, this part won't be executed
          },
        ),
        bottomNavigationBar: ConvexAppBar(
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.access_time, title: 'Prayer Times'),
            TabItem(icon: Icons.book, title: 'Quran'),
            TabItem(icon: Icons.location_on, title: 'Map'),
          ],
          initialActiveIndex: _selectedIndex, // Set the active index
          onTap: (index) {
            _onTabTapped(index); // Handle tab taps
          },
          backgroundColor: Colors.blue,
          activeColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildPrayerTimesUI() {
    final myCoordinates = Coordinates(latitude!, longitude!);

    // Switch between Hanafi and Shafi based on user selection
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = isHanafi ? Madhab.hanafi : Madhab.shafi; // Set based on the switch
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPrayerTimeRow('Fajr', prayerTimes.fajr),
          Divider(color: Colors.black, thickness: 1),
          buildPrayerTimeRow('Dhuhr', prayerTimes.dhuhr),
          Divider(color: Colors.black, thickness: 1),
          buildPrayerTimeRow('Asr', prayerTimes.asr),
          Divider(color: Colors.black, thickness: 1),
          buildPrayerTimeRow('Maghrib', prayerTimes.maghrib),
          Divider(color: Colors.black, thickness: 1),
          buildPrayerTimeRow('Isha', prayerTimes.isha),
        ],
      ),
    );
  }

  Widget buildPrayerTimeRow(String prayerName, DateTime prayerTime) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formatPrayerTime(prayerTime),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check for location permissions
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get current location
    _currentPosition = await location.getLocation();
    latitude = _currentPosition?.latitude;
    longitude = _currentPosition?.longitude;

    if (latitude == null || longitude == null) {
      throw Exception('Failed to get location.');
    }

    setState(() {
      locationFetched = true; // Mark the location as fetched to trigger UI update
    });
  }

  String formatPrayerTime(DateTime time) {
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(time);
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        Get.offNamed('/home'); // Navigate to Home screen
        break;
      case 1:
        Get.offNamed('/prayer'); // Stay on Prayer screen
        break;
      case 2:
        Get.offNamed('/quran'); // Navigate to Quran screen
        break;
      case 3:
        Get.offNamed('/map'); // Navigate to Map screen
        break;
    }
  }
}
