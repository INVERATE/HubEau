import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'appconstant.dart';
import '../models/station_model.dart';
import '../services/api.dart';
import 'package:provider/provider.dart';
import '../provider/station_provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(46.232193, 2.209667); // Centre France

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  /// Charge les stations depuis l'API et les transforme en markers
  Future<void> _loadStations() async {
    try {
      List<Station> stations = await HubEauAPI().getStationListByDepartment("94");

      Set<Marker> stationMarkers = stations.map((station) {
        return Marker(
          markerId: MarkerId(station.code),
          position: LatLng(station.latitude, station.longitude),
          infoWindow: InfoWindow(
            title: station.libelle,
            onTap: () {
              Provider.of<StationProvider>(context, listen: false).selectStation(station);
            },
          ),
        );
      }).toSet();

      setState(() {
        _markers = stationMarkers;
      });
    } catch (e) {
      print("Erreur lors du chargement des stations : $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _moveToNewLoc() {
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(40.7128, -74.0060)), // New York
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 6),
        markers: _markers,
      ),
    );
  }
}
