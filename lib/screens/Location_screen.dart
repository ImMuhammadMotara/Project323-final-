import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  final Location location = Location();
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  bool _isLoading = true; // Loading indicator for map

  // Lists to hold restaurant and mosque names
  final List<String> _restaurants = [];
  final List<String> _mosques = [];
  bool _showRestaurants = true; // Flag to toggle between restaurants and mosques

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchPlaces();
  }

  Future<void> _initializeLocationAndFetchPlaces() async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      // Check if location services are enabled
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          _showErrorDialog('Location services are disabled.');
          return;
        }
      }

      // Check for location permissions
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          _showErrorDialog('Location permissions are denied.');
          return;
        }
      }

      // Fetch the current location
      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      // Fetch nearby restaurants and mosques
      await Future.wait([
        _fetchNearbyPlaces(_currentLocation!, 'restaurant'),
        _fetchNearbyPlaces(_currentLocation!, 'mosque'),
      ]);
    } catch (e) {
      _showErrorDialog('Error getting location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyPlaces(LatLng location, String placeType) async {
    final apiKey = 'AIzaSyBKTX-hMw9rA5v9IPRoyAg0aXO8bFyazc4'; // Replace with your API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=1500&type=$placeType&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;

        if (results.isEmpty) {
          // Optionally handle no results found
          return;
        }

        setState(() {
          if (placeType == 'restaurant') {
            _restaurants.clear();
            _restaurants.addAll(results.take(5).map<String>((result) => result['name'].toString()));
          } else if (placeType == 'mosque') {
            _mosques.clear();
            _mosques.addAll(results.take(5).map<String>((result) => result['name'].toString()));
          }

          // Add markers for each place
          for (var result in results.take(5)) {
            final placeId = result['place_id'];
            final name = result['name'];
            final lat = result['geometry']['location']['lat'];
            final lng = result['geometry']['location']['lng'];

            // Avoid duplicate markers
            if (!_markers.any((marker) => marker.markerId.value == placeId)) {
              _markers.add(
                Marker(
                  markerId: MarkerId(placeId),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: name),
                ),
              );
            }
          }
        });
      } else {
        _showErrorDialog('Failed to load nearby places (Status Code: ${response.statusCode}).');
      }
    } catch (e) {
      _showErrorDialog('Error fetching nearby places: $e');
    }
  }

  void _togglePlaceType() {
    if (_showRestaurants) {
      _showNearestMosqueDialog();
    } else {
      _showNearestRestaurantDialog();
    }
  }

  void _showNearestMosqueDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Find Nearest Mosque'),
          content: const Text('Would you like to find the nearest mosque?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (_currentLocation != null) {
                  _fetchNearbyPlaces(_currentLocation!, 'mosque'); // Fetch mosques only
                  setState(() {
                    _showRestaurants = false; // Automatically show mosques
                  });
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showNearestRestaurantDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Find Nearest Restaurant'),
          content: const Text('Would you like to find the nearest restaurant?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (_currentLocation != null) {
                  _fetchNearbyPlaces(_currentLocation!, 'restaurant'); // Fetch restaurants only
                  setState(() {
                    _showRestaurants = true; // Automatically show restaurants
                  });
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlacesList() {
    final places = _showRestaurants ? _restaurants : _mosques;
    final title = _showRestaurants ? 'Nearby Restaurants' : 'Nearby Mosques';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Shrink-wrap the column
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Constrain the height of the ListView
          SizedBox(
            height: 150, // Adjust the height as needed
            child: places.isEmpty
                ? const Center(child: Text('No places found.'))
                : ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(_showRestaurants ? Icons.restaurant : Icons.mosque),
                  title: Text(places[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          actions: [
            IconButton(
              icon: Icon(_showRestaurants ? Icons.restaurant : Icons.mosque),
              onPressed: _togglePlaceType,
              tooltip: _showRestaurants ? 'Show Mosques' : 'Show Restaurants',
            ),
          ],
        ),
        body: Column(
          children: [
            // Map Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _currentLocation == null
                  ? const Center(child: Text('Failed to get location'))
                  : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            // Places List Section
            _buildPlacesList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showNearestMosqueDialog,
          child: const Icon(Icons.location_searching),
          tooltip: 'Find Nearest Mosque',
        ),
      ),
    );
  }
}
