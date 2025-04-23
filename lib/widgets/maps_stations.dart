import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/station_model.dart';
import '../services/api.dart';
import 'dart:async';
import '../provider/observation_provider.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final void Function(String stationCode)? onStationSelected;

  const MapScreen({super.key, this.onStationSelected});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(46.232193, 2.209667);  // Le centre de la maps est le Centre France
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;   // Creation d'un icon personalisé (bleu)
  BitmapDescriptor markerIconGrey = BitmapDescriptor.defaultMarker;   // Creation d'un icon personalisé (gris)
  Set<Marker> _markers = {};  // liste de markers car on a 2 type d'icons pour les markers
  //Uint8List? marketimages;  // Truc pour que les images des markers s'affiche bien
  List<String> images = ['goutte-deau.png','goutte-deau-gris.png'];   // Les 2 fameux markers

  // Declaration de la méthodes pour avoir les images
  //Future<Uint8List> getImages(String path, int width) async{
  //  ByteData data = await rootBundle.load(path);
  //  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
  //  ui.FrameInfo fi = await codec.getNextFrame();
  //  return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  //}

  String? _lastDep;   // permet de dire : si _lastDep est pas là c'est pas grave
  @override
  // méthode pour récuperer le departement sélectionné
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDep = Provider.of<ObservationProvider>(context).selectedDepartment;   // provider notifie toute les fonctions abonnées au provider quand y'a un changement ici le département
    if (selectedDep != null && selectedDep != _lastDep) {
      _lastDep = selectedDep;  // _lastDep : departement précédement sélectionner
      _loadStations(selectedDep); // faire les stations du departement choisit
    }
  }

  // Ce qui est initialisé au lancement du dashboard
  @override
  void initState() {
    super.initState();
    addCustomMarkerBlue();  // le marker spécial bleu
    addCustomMarkerGrey();  // le marker spécial gris
    _loadStations("75");  // Charge toutes les stations au démarrage, mettre un département si besoin
  }

  // méthode pour avoir les markers bleu
  void addCustomMarkerBlue(){
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),   // ici avec asset on configure les markers (taille + image)
        'goutte-deau.png').then(
            (icon){
          setState(() {
            markerIcon = icon;  // on créer un état de markers ici markerIcon sera le bleu
          });
        }
    );
  }

  // pareil pour les gris
  void addCustomMarkerGrey(){
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)), // taille suggérée
        'goutte-deau-gris.png').then(
            (icon){
          setState(() {
            markerIconGrey = icon;
          });
        }
    );
  }

  // Charge les stations depuis l'API et les transforme en markers
  Future<void> _loadStations([String? dep]) async {
    try {

      // ici on créer une liste avec les stations qui ont des info : enservice: true, elles auront des markers bleu
      List<Station> stations_enService = await HubEauAPI().getStations(department: dep, enService: true);

      // ici on créer une liste avec les stations qui ont PAS d'info : enservice: false, elles auront des markers gris
      List<Station> stations_horsService = await HubEauAPI().getStations(department: dep, enService: false);

      // Placement des markers sur la carte
      // on fait un map sur la liste stations_enService comme ca on pourra avoir les stations de la liste (nommé stationMarkers) 1 part 1
      Set<Marker> stationMarkers = stations_enService.map((station) {
        return Marker(    // pour chaque stations on revoit un markers qui aura
          markerId: MarkerId(station.code),   // comme ID le code de la station
          position: LatLng(station.latitude, station.longitude),  // pour position la latitude et la longitude de la station
          infoWindow: InfoWindow(
            title: station.libelle,   // et une petite popo up avec son libelle quand on clique sur le markers
            snippet: "Station en service",
            ),
            onTap: () {   // cela permettra de faire marcher les graph quand on tape sur le markers
              widget.onStationSelected?.call(station.code);   // Appel du callback, permet de passer la station sélectionnée au parent
              print("Station sélectionnée : ${station.code}");
            },
            icon: markerIcon   // le markers sera le bleu
        );
      }).toSet();


      // de même pour la liste stations_horsService sauf que le markers sera gris
      Set<Marker> stationMarkers_horsService = stations_horsService.map((station) {
        return Marker(
            markerId: MarkerId(station.code),
            position: LatLng(station.latitude, station.longitude),
            infoWindow: InfoWindow(
              title: station.libelle,
              snippet: "Station hors service",

            ),
            onTap: () {
              widget.onStationSelected?.call(station.code);   // Appel du callback, permet de passer la station sélectionnée au parent
              print("Station sélectionnée : ${station.code}");
            },
            icon: markerIconGrey  // markers gris
        );
      }).toSet();

      // on affiche les markers grace a setState
      // si on inverse les 2 ligne, c'est la première ligne qui s'executera en première
      setState(() {
        _markers = stationMarkers_horsService;
        _markers.addAll(stationMarkers);  // Ajoute les markers des stations en service après, pour les afficher en premier plan
      });

      if (stations_enService.isNotEmpty) {
        final firstStation = stations_enService.first;
        mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(firstStation.latitude, firstStation.longitude),
        ));
      }

      // petite impression des erreur s'il y en a
    } catch (e, stacktrace) {
      print("Erreur lors du chargement des stations : $e");
      print("Stacktrace : $stacktrace");
    }
  }


  // c'est finit avec les markers on fait la carte maintenant

  // methode de creation de la carte
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // implémentation de la carte google maps
  @override
  Widget build(BuildContext context) {
    return Card(// elle se situe dans une card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // ici tu choisis le rayon
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(   // la voila
        mapType: MapType.terrain,   // terrain pour avoir les reliefs (il existe aussi normal, hybrid, satellite
        onMapCreated: _onMapCreated,  // on fait appel à la méthode pour la carte
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 5),   // elle est zoommer sur 6 comme ca on voit toute la France, plus on zoom plus c'est proche
        markers: _markers,  // on place notre liste de markers
      ),
    );
  }
}
