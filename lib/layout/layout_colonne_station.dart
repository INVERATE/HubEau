// Widgets
import '../widgets/test_widget.dart';
import '../widgets/station_graph.dart';
import '../widgets/station_favorites.dart';
import '../widgets/maps_stations.dart';
import '../widgets/station_details.dart';

//Layout
import '../layout/layout_colonne_station.dart';

// gestion des données
import '../provider/observation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_bar.dart';


class ColonneStation extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<ObservationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Erreur : ${provider.error}'));
        }

        return ListView(
          children: [
            FlowChart(observations: provider.hauteur, type: "H"),
            FlowChart(observations: provider.debit, type: "Q"),
            FavoriteStationsWidget(),
          ],
        );
      },
    );
  }
}
