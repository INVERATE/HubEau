import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../provider/observation_provider.dart';
import '../models/station_model.dart';
import '../services/api.dart';
import 'package:provider/provider.dart';


class MapScreen extends StatefulWidget {
  final void Function(String stationCode)? onStationSelected;

  const MapScreen({super.key, this.onStationSelected});
  @override
  _MapScreenState createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(46.232193, 2.209667); // Centre France

  Set<Marker> _markers = {};
  String? _lastDep;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDep = Provider.of<ObservationProvider>(context).selectedDepartment;
    if (selectedDep != null && selectedDep != _lastDep) {
      _lastDep = selectedDep;
      _loadStations(selectedDep);
    }
  }

  @override
  void initState() {
    super.initState();
    //_loadStations("75");
    _loadStations("75"); // Charge toutes les stations au démarrage, mettre un département si besoin
  }

  /// Charge les stations depuis l'API et les transforme en markers
  Future<void> _loadStations([String? dep]) async {
    try {
      //List<String> dep = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95"];

      //List<String> dep = ["75", "92", "93", "94", "95"];
      //List<String> dep = [value];

      //List<Future<List<Station>>> futures = dep.map((codeDep) {
      //  return HubEauAPI().getStationListByDepartment(codeDep);
      //}).toList();

      //List<List<Station>> allStationsLists = await Future.wait(futures);



// Aplatir la liste de listes en une seule liste
      //List<Station> stations = allStationsLists.expand((list) => list).toList();


      //List<Station> stations = await HubEauAPI().getStationListByDepartment("95");
      //List<Station> stations = await HubEauAPI().getAllStations();

      List<Station> stations_enService = await HubEauAPI().getStations(department: dep, enService: true);

      Set<Marker> stationMarkers = stations_enService.map((station) {
        return Marker(
          markerId: MarkerId(station.code),
          position: LatLng(station.latitude, station.longitude),
          infoWindow: InfoWindow(
            title: station.libelle,
          ),
          onTap: () {
            widget.onStationSelected?.call(station.code); // Appel du callback, permet de passer la station sélectionnée au parent
            print("Station sélectionnée : ${station.code}");
          },
        );
      }).toSet();

      setState(() {
        _markers = stationMarkers;
      });
    } catch (e, stacktrace) {
      print("Erreur lors du chargement des stations : $e");
      print("Stacktrace : $stacktrace");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //void _moveToNewLoc() {
  //  mapController.animateCamera(
  //    CameraUpdate.newLatLng(LatLng(40.7128, -74.0060)), // New York
  //  );
  //}

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 6),
          markers: _markers,
        ),
      ),
    );
  }
}
