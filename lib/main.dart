import 'package:flutter/material.dart';
import '../widgets/test_widget.dart';
import '../widgets/flow_charts.dart';
import '../models/flow_observation.dart';
import '../services/hub_eau_flow.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HubEau Stations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<FlowObservation>> _futureObservations;

  @override
  void initState() {
    super.initState();
    _futureObservations = HubEauFlow().getFlowByStationAndDate('O919001001', '2025-03-30');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observations de débit et hauteur ${"O919001001"}')),
      backgroundColor: Colors.blue[100],
      body: FutureBuilder<List<FlowObservation>>(
        future: _futureObservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          List<FlowObservation> observations = snapshot.data!;
          List<FlowObservation> hauteurData = filterByType(observations, "H");
          List<FlowObservation> debitData = filterByType(observations, "Q");

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:
              Row(
                children: [
                  Container(
                    width: 600,
                    height: 525,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text("Map", style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 50,
                  ),
                  Column(
                    children: [
                      Center(child:
                      Column(children: [
                        Container(
                          width: 500,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                              child :ListView(
                                children: [
                                  FlowChart(observations: hauteurData, type: "H"),
                                ],
                              ),
                          ),

                        ),
                        SizedBox(height: 25
                        ),
                        Container(
                          width: 500,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child :ListView(
                              children: [
                                FlowChart(observations: debitData, type: "Q"),
                              ],
                            ),
                          ),

                        ),

                      ],
                      ),

                      )

                    ],

                  ),

                ],
              ),

            ),
          );
        },
      ),
    );
  }
}
