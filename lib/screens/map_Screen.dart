import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(21.4225, 39.8262), // Example: Mecca's location
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('mecca'),
            position: LatLng(21.4225, 39.8262),
            infoWindow: InfoWindow(
              title: 'Kaaba',
              snippet: 'The center of the Islamic world',
            ),
          ),
        },
      ),
    );
  }
}
