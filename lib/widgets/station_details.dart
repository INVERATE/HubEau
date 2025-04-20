import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart';
import '../models/station_model.dart';
import '../services/api.dart';

class StationDetails extends StatefulWidget {
  const StationDetails({super.key});

  @override
  _StationDetailsState createState() => _StationDetailsState();
}

class _StationDetailsState extends State<StationDetails> {
  Future<Station>? _stationFuture;
  String? _lastStationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedStation = Provider.of<ObservationProvider>(context).stationId;

    // Ne recharge que si l'ID de la station change
    if (selectedStation != null && selectedStation != _lastStationId) {
      _lastStationId = selectedStation;
      _stationFuture = HubEauAPI().getStationByCode(selectedStation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = Provider.of<ObservationProvider>(context).stationId;

    if (selectedStation == null) {
      return _buildCard("Aucune station sélectionnée");
    }

    return FutureBuilder<Station>(
      future: _stationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard("Chargement des informations...");
        } else if (snapshot.hasError) {
          return _buildCard("Erreur : ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return _buildCard("Aucune donnée trouvée");
        }

        final station = snapshot.data!;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Station : ${station.libelle}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Code : ${station.code}"),
                Text("Code postal : ${station.codePostal}"),
                Text("Latitude : ${station.latitude}"),
                Text("Longitude : ${station.longitude}"),
                if (station.commentaire != null)
                  Text("Commentaire : ${station.commentaire}"),
                Text("En service : ${station.enService ? 'Oui' : 'Non'}"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(String message) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(message),
      ),
    );
  }
}
