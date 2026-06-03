import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMapsScreen extends StatelessWidget {
  const TestMapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Google Maps')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.8891, 10.1050), // Gabès
          zoom: 12,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('test'),
            position: LatLng(33.8891, 10.1050),
            infoWindow: InfoWindow(title: 'Gabès'),
          ),
        },
      ),
    );
  }
}