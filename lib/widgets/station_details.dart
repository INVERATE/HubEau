import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/station_provider.dart';

class StationDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedStation = Provider.of<StationProvider>(context).selectedStation;

    if (selectedStation == null) {
      return Center(child: Text("Clique sur un point de la carte pour voir les détails"));
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Station : ${selectedStation.libelle}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(height: 12),
            // Tu peux ajouter ici un widget graphique
            Placeholder(fallbackHeight: 100), // Remplace par ton widget de graphique
          ],
        ),
      ),
    );
  }
}
