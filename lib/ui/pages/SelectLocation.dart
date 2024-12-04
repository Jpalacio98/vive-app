import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

class SelectLocationWidget extends StatefulWidget {
  final Function(LatLng) onLocationSelected; // Callback para retornar la ubicación seleccionada

  SelectLocationWidget({required this.onLocationSelected});

  @override
  _SelectLocationWidgetState createState() => _SelectLocationWidgetState();
}

class _SelectLocationWidgetState extends State<SelectLocationWidget> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Ubicación por defecto
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    mapController.moveCamera(CameraUpdate.newLatLng(_selectedLocation));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _confirmLocation() {
    widget.onLocationSelected(_selectedLocation); // Llama al callback con la ubicación seleccionada
    Navigator.pop(context); // Cierra el widget de selección de ubicación
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation, // Botón para confirmar la ubicación
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onMapTap,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _selectedLocation,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}