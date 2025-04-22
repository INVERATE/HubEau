import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart';
import '../models/station_model.dart';
import '../services/api.dart';

// Classe qui affiche les informations de la station
class StationDetails extends StatefulWidget {
  const StationDetails({super.key});

  @override
  _StationDetailsState createState() => _StationDetailsState();
}

// Etat de la classe StationDetails
class _StationDetailsState extends State<StationDetails> {
  Future<Station>? _stationFuture;
  String? _lastStationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupère la station sélectionnée depuis le Provider
    // mais ne recharge que si UNIQUEMENT l'ID de la station change, pas d'autres variables
    final selectedStation = Provider.of<ObservationProvider>(context).stationId;

    // Ne recharge que si l'ID de la station change
    if (selectedStation != null && selectedStation != _lastStationId) {
      _lastStationId = selectedStation; // Stocke l'ID de la station pour la prochaine fois
      _stationFuture = HubEauAPI().getStationByCode(selectedStation); // Charge les données de la station
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = Provider.of<ObservationProvider>(context).stationId;

    // Si aucune station n'est sélectionnée, affiche un message
    if (selectedStation == null) {
      return _buildCard("Aucune station sélectionnée");
    }

    // Si le chargement de l'API n'est pas encore terminé, affiche un message de chargement
    return FutureBuilder<Station>(
      future: _stationFuture,
      builder: (context, snapshot) {
        // Si le chargement n'est pas terminé, affiche un message de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard("Chargement des informations...");
        } else if (snapshot.hasError) {
          return _buildCard("Erreur : ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return _buildCard("Aucune donnée trouvée");
        }

        // Récupère les données de la station
        final station = snapshot.data!;

        // Affiche les informations de la station
        return Card(
          
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de la station avec icône et couleur de l'état "En service"
                Row(
                  children: [
                    // Icône de l'état "En service" avec 2 couleurs
                    Icon(
                      station.enService ? Icons.check_circle : Icons.cancel,
                      color: station.enService ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // Titre du widget
                      child: Text(
                        "Station : ${station.libelle}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Titre souligné "Code" et "Code Commune"
                Row(
                  children: [
                    // _buildSectionTitle est une méthode qui retourne un widget Text avec le titre en gras et une taille de police de 12
                    _buildSectionTitle("Code : "),
                    Text(station.code, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    SizedBox(width: 8),
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
                // Si le commentaire est null, le widget n'est pas affiché
                if (station.commentaire != null)
                  // GestureDetector permet de détecter un clic sur le widget
                  GestureDetector(
                    // On appelle la méthode _showCommentDialog lorsque le widget est cliqué
                    onTap: () => _showCommentDialog(context, station.commentaire!),
                    child: Row(
                      children: [
                        _buildSectionTitle("Commentaire : "),
                        Expanded(
                          child: Text(
                            "Ouvrir",
                            style: TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold),
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

  // Méthode qui retourne un widget Text avec le titre en gras et une taille de police de 12
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  // Méthode qui affiche un popup avec le commentaire
  void _showCommentDialog(BuildContext context, String comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Commentaire complet"),
          // Widget qui peut être scrollé
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(comment),
              ],
            ),
          ),

          // Boutons de fermeture du popup
          actions: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.close, color: Colors.indigoAccent),
              label: Text("Fermer"),

              // Ferme le popup
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Méthode qui retourne un widget Card avec un message à l'intérieur
  // Le message peut être une erreur ou un message de chargement
  Widget _buildCard(String message) {
    return Card(

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(message),
      ),
    );
  }
}
