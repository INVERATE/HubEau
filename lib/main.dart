import 'package:flutter/material.dart';

// Widgets
import '../widgets/test_widget.dart';
import '../widgets/flow_charts.dart';
// Modèle de gestion des données de l'API
import '../models/flow_observation.dart';
// service de communication avec l'API
import '../services/hub_eau_flow.dart';


// Démarrage de l'application
void main() {
  runApp(const MyApp());
}

// Déclaration de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Déclaration des propriétés
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HubEau Stations', // nom de l'onglet
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}


// Page pricipale
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


// Etat de la page pricipale
class _MyHomePageState extends State<MyHomePage> {
  late Future<List<FlowObservation>> _futureObservations;

  // Initialisation des données
  @override
  void initState() {
    super.initState();
    _futureObservations = HubEauFlow().getFlowByStationAndDate('O919001001', '2025-03-30');
  }

  // Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observations de débit et hauteur ${"O919001001"}')),
      body: FutureBuilder<List<FlowObservation>>(
        future: _futureObservations,
        builder: (context, snapshot) {

          // Gestion des erreurs
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          // Récupération des données
          List<FlowObservation> observations = snapshot.data!;
          List<FlowObservation> hauteurData = filterByType(observations, "H");
          List<FlowObservation> debitData = filterByType(observations, "Q");

          // Affichage des Widgets
          return ListView(
            children: [
              FlowChart(observations: hauteurData, type: "H"),
              FlowChart(observations: debitData, type: "Q"),
              TestWidget()
            ],
          );
        },
      ),
    );
  }
}
