import 'dart:async';
import 'package:firebase_core/firebase_core.dart'; // Firebase import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muslim_app_4/screens/home_screen.dart';
import 'package:muslim_app_4/screens/main_screen.dart';
import 'package:muslim_app_4/screens/prayer_screen.dart';
import 'package:muslim_app_4/screens/quraan_screen.dart';
import 'package:muslim_app_4/screens/Location_screen.dart'; // Import MapScreen
import 'firebase_options.dart';  // Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set MainScreen as the initial route
    return GetMaterialApp(
      title: 'Muslim Locator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home', // Set HomeScreen as the initial route
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/prayer', page: () => PrayerScreen()),
        GetPage(name: '/quran', page: () => QuraanScreen()),
        GetPage(name: '/map', page: () => LocationScreen()), // Correct MapScreen route
      ],
    );
  }
}


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is authenticated
    User? user = FirebaseAuth.instance.currentUser;

    // If user is not logged in, navigate to a loading screen or fallback
    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading while checking
      );
    }

    // If user is authenticated, display MainScreen
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Main Screen!'),
      ),
    );
  }
}
