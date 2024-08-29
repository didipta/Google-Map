import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final List<LatLng> _polylinePoints = [];
  Polyline? _polyline;
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _locationPermissionHandler(() {
      _getCurrentLocation();
      _listenToLocationUpdates();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0,
        );
      });
      _updateLocation(position);
    } catch (e) {
      // Handle the error, e.g., by showing a dialog or message
      print('Error fetching location: $e');
    }
  }

  void _listenToLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentPosition = position;
      final latLng = LatLng(position.latitude, position.longitude);

      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: latLng,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );

      _polylinePoints.add(latLng);
      _polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: _polylinePoints,
        color: Colors.blue,
        width: 5,
      );

      _animateToUserLocation();
    });
  }

  void _animateToUserLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _locationPermissionHandler(VoidCallback startService) async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Permission granted
      final bool isEnable = await Geolocator.isLocationServiceEnabled();
      if (isEnable) {
        // START THE PROVIDED SERVICE
        startService();
      } else {
        // Turn on GPS service
        Geolocator.openLocationSettings();
      }
    } else {
      // Permission denied
      if (permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return;
      }
      LocationPermission requestPermission =
      await Geolocator.requestPermission();
      if (requestPermission == LocationPermission.always ||
          requestPermission == LocationPermission.whileInUse) {
        _locationPermissionHandler(startService);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        backgroundColor: Colors.blue,
      ),
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: _initialCameraPosition!,
        markers: _markers,
        polylines: _polyline != null ? {_polyline!} : {},
      ),
    );
  }
}
