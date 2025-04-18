import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/observation_model.dart';
import '../place_service.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();

}
class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(46.232193 , 2.209667); // France



  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(title: "Custom Location"), // nom du fleuve à mettre à partir de l'api

        ),
      );
    });
  }

  void _moveToNewLoc() {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(40.7128, -74.0060)), // New York
    );
  }

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId("hello"),
        position: _initialPosition,
        //position: LatLng( , ),
        infoWindow: InfoWindow( title : "san fran", snippet: "A beautiful city!"),
      ),
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Interactive Map in Flutter")),
        body: GoogleMap(
          onTap: _onMapTapped,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 6),
          markers: _markers,
        )
    );
  }
}