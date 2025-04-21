// Widgets
import '../../widgets/test_widget.dart';
import '../../widgets/station_graph.dart';
import '../../widgets/station_favorites.dart';
import '../../widgets/maps_stations.dart';
import '../../widgets/station_details.dart';

// gestion des données
import '../../provider/observation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/search_bar.dart';




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ObservationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ObservationProvider();
  }

  // Fonction appelée lorsque l'utilisateur sélectionne une station
  void _handleStationSelected(String stationCode) {
    // Récupérerles données de l'API jusqu'au mois dernier plus 1 jour
    _provider.selectStation(stationCode, DateTime.now().subtract(Duration(days: 30)).toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: _provider,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(children: [MapScreen(onStationSelected: _handleStationSelected), SizedBox(
                      height: 100,
                      child: Search_Bar(),
                    )]),
                  ),
                  FavoriteStationsWidget(onStationSelected: _handleStationSelected),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  StationDetails(),

                  // Partie dynamique : uniquement les widgets qui dépendent du provider
                  Consumer<ObservationProvider>(
                    builder: (context, provider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FlowChart(observations: provider.hauteur, type: "H", isLoading: provider.isLoading),
                          FlowChart(observations: provider.debit, type: "Q", isLoading: provider.isLoading),
                        ],
                      );
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


