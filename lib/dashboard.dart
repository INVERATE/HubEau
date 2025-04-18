// Widgets
import '../widgets/test_widget.dart';
import '../widgets/station_graph.dart';
import '../widgets/station_favorites.dart';
// gestion des données
import '../provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/maps_stations.dart';





// Page principale
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ObservationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Observations Station ${provider.stationId ?? "..."}')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Erreur : ${provider.error}'));
          }
          if (provider.observations.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          print('Hauteur: ${provider.hauteur.length}, Débit: ${provider.debit.length}');


          return Row(
            children: [
              Expanded(
                child: MapScreen()
              ),
              Expanded(
                child: ListView(
                  children: [
                    FlowChart(observations: provider.hauteur, type: "H"),
                    FlowChart(observations: provider.debit, type: "Q"),
                    FavoriteStationsWidget(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
