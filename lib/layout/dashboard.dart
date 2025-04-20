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

  void _handleStationSelected(String stationCode) {
    _provider.selectStation(stationCode, "2025-04-12");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('HubEau'),
            const SizedBox(width: 8),
            const Icon(Icons.water_drop),
          ],
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _provider,
        child: Column(
          children: [
            // 🔹 Barre de recherche + StationDetails alignés
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 100,
                      child: Search_Bar(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: StationDetails(),
                  ),
                ],
              ),
            ),
            // 🔹 Le corps principal : carte à gauche, données à droite
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: MapScreen(onStationSelected: _handleStationSelected),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Consumer<ObservationProvider>(
                          builder: (context, provider, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FlowChart(
                                  observations: provider.hauteur,
                                  type: "H",
                                  isLoading: provider.isLoading,
                                ),
                                const SizedBox(height: 16),
                                FlowChart(
                                  observations: provider.debit,
                                  type: "Q",
                                  isLoading: provider.isLoading,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FavoriteStationsWidget(
                          onStationSelected: _handleStationSelected,
                        ),
                      ],
                    ),
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
