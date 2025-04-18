import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'appconstant.dart';
//import 'dart:async';
//import '../services/hub_eau_flow.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();

}
class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(46.232193 , 2.209667); // France

  //late Future<List<FlowObservation>> _futureLatLong;
  //Completer<GoogleMapController> _controller = Completer();

  Iterable markers = [];

  final Iterable _markers = Iterable.generate(AppConstant.list.length, (index) {
    return Marker(
        markerId: MarkerId(AppConstant.list[index]['id']),
        position: LatLng(
          AppConstant.list[index]['lat'],
          AppConstant.list[index]['lon'],
        ),
        infoWindow: InfoWindow(title: AppConstant.list[index]["title"])
    );
  });

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  void _moveToNewLoc() {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(40.7128, -74.0060)), // New York
    );
  }

  //Set<Marker> _markers = {};

  @override
  void initState() {
    markers = _markers; /////////////////////////////
    super.initState();

    //_markers.add(
    //  Marker(
    //    markerId: MarkerId("hello"),
    //position: _initialPosition,
    //    position: LatLng( , ),
    //    infoWindow: InfoWindow( title : "san fran", snippet: "A beautiful city!"),
    //  ),
    //);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Interactive Map in Flutter")),
        body: GoogleMap(
          //onTap: _onMapTapped,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 6),
          //markers: _markers,
          markers: Set.from(markers),
        )
    );
  }
}