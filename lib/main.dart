import 'package:flutter/material.dart';

//widgets
import '../widgets/flow_charts.dart';
import '../widgets/test_widget.dart';
//modeles d'organisation des données
import '../models/flow_observation.dart';
//Communication avec l'API
import '../services/hub_eau_flow.dart';


// Démarrage de l'application
void main() {
  runApp(const MyApp());
}


// Classe principale de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HubEau Stations', //nom de l'onglet / application
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}


// Page d'accueil de l'application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


// Etat de la page d'accueil
class _MyHomePageState extends State<MyHomePage> {
  late Future<List<FlowObservation>> _futureObservations;

  // Initialisation des données par défaut de la page
  @override
  void initState() {
    super.initState();
    _futureObservations = HubEauFlow().getFlowByStationAndDate('O919001001', '2025-03-30');
  }

  // Affichage des widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observations de débit et hauteur ${"O919001001"}')),
      body: FutureBuilder<List<FlowObservation>>(
        future: _futureObservations,
        builder: (context, snapshot) {

          // Gestion des différents états/erreurs de chargement des données
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          // Récupération des données à partir de l'API
          List<FlowObservation> observations = snapshot.data!;
          List<FlowObservation> hauteurData = filterByType(observations, "H");
          List<FlowObservation> debitData = filterByType(observations, "Q");

          // Affichage des widgets
          return ListView(
            children: [
              FlowChart(observations: hauteurData, type: "H"),
              FlowChart(observations: debitData, type: "Q"),
              TestWidget(),
            ],
          );
        },
      ),
    );
  }
}
