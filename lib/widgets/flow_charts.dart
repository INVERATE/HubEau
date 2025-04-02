import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/flow_observation.dart';

class FlowChart extends StatelessWidget {
  final List<FlowObservation> observations;
  final String type; // "H" ou "Q"

  const FlowChart({super.key, required this.observations, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              type == "Q" ? "Débit (m³/s)" : "Hauteur (cm)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: observations.asMap().entries.map((entry) {
                        int index = entry.key;
                        double value = entry.value.resultatObs;
                        return FlSpot(index.toDouble(), value);
                      }).toList(),
                      isCurved: true,
                      color: "Q" == type ? Colors.green : Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
