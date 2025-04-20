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
                // Nom de la station avec icône et couleur en fonction de l'état "En service"
                Row(
                  children: [
                    Icon(
                      station.enService ? Icons.check_circle : Icons.cancel,
                      color: station.enService ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Station : ${station.libelle}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Titre souligné "Code"
                Row(
                  children: [
                    _buildSectionTitle("Code : "),
                    Text(station.code, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),

                // Titre souligné "Code commune"
                Row(
                  children: [
                    _buildSectionTitle("Code commune : "),
                    Text(station.codeCommune, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),

                // Titre souligné "Latitude / Longitude"
                Row(
                  children: [
                    _buildSectionTitle("Latitude / Longitude : "),
                    Expanded(child: Text("${station.latitude} / ${station.longitude}", overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 8),

                // Affichage du commentaire sous forme de texte abrégé avec un popup
                if (station.commentaire != null)
                  GestureDetector(
                    onTap: () => _showCommentDialog(context, station.commentaire!),
                    child: Row(
                      children: [
                        _buildSectionTitle("Commentaire : "),
                        Expanded(
                          child: Text(
                            "Ouvrir",
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                            overflow: TextOverflow.ellipsis,

                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  void _showCommentDialog(BuildContext context, String comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Commentaire complet"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(comment),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
