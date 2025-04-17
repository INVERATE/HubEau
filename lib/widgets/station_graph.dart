import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/station_model.dart';
import 'package:intl/intl.dart';

class FlowChart extends StatelessWidget {
  final List<Observation> observations;
  final String type; // "Q" ou "H"
  const FlowChart({super.key, required this.observations, required this.type});

  @override
  Widget build(BuildContext context) {
    if (observations.isEmpty) {
      return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(
                  type == "Q" ? "Débit (m³/s)" : "Hauteur (cm)",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: const Center(child: Text('Aucune donnée disponible.')),
                  )
                ],
              )
          )
      );
    }

    final spots = observations.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.resultatObs);
    }).toList();

    final moyenne = observations.map((e) => e.resultatObs).reduce((a, b) => a + b) / observations.length;

    final dateLabels = observations.map((obs) {
      return DateFormat('dd/MM').format(obs.dateObs);
    }).toList();
    final dateHourLabels = observations.map((obs) {
      return DateFormat('dd/MM HH:mm').format(obs.dateObs);
    }).toList();

    final values = observations.map((e) => e.resultatObs).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    // Ajouter une marge de 5%
    final range = maxVal - minVal;
    final margin = range * 0.05;
    final minY = (minVal - margin).clamp(double.negativeInfinity, double.infinity).toDouble();
    final maxY = maxVal + margin;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              type == "Q" ? "Débit (m³/s)" : "Hauteur (cm)",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: observations.length.toDouble(),
                    minY: minY,
                    maxY: maxY,

                    // Affichage des infos sur les points
                    lineTouchData: LineTouchData(
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        // Empêche les tooltips sur la ligne de moyenne
                        if (barData.color == Colors.redAccent) return [];
                        return spotIndexes.map((index) => TouchedSpotIndicatorData(
                          FlLine(color: type == "Q" ? Colors.green : Colors.blue, strokeWidth: 2, dashArray: [5, 5]),
                          FlDotData(show: true),
                        )).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black54,
                        getTooltipItems: (spots) {
                          return spots
                              .map((spot) => LineTooltipItem(
                            '${dateHourLabels[spot.spotIndex]}\n${spot.y.toStringAsFixed(1)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          )).toList();
                        },
                      ),
                    ),

                    // Affichage des valeurs sur l'axe y
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 70,
                          interval: (range / 5).clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) {
                            // Ne pas afficher les valeurs très proches du min et du max
                            if ((value - minY).abs() < 1e-2 || (value - maxY).abs() < 1e-2) {
                              return const SizedBox.shrink();
                            }
                            return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12));
                          },
                        ),
                      ),

                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      // Affichage des dates en bas
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (observations.length / 5).floorToDouble().clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < dateLabels.length) {
                              return Text(
                                dateLabels[index],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),


                    // Affichage de la grille et de la bordure
                    borderData: FlBorderData(show: true, border: Border.all(color: Colors.black26, width: 2)),
                    gridData: FlGridData(show: true,
                      getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.black12, strokeWidth: 1);
                      },
                      getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.black12, strokeWidth: 1);
                      },
                    ),

                    lineBarsData: [
                      // Graphique principal
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: type == "Q" ? Colors.green : Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],

                    // Ajout de la ligne de moyenne
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: moyenne,
                        color: Colors.black54,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(show: false),
                      ),
                    ]),
                  ),
                ),

                  // Affichage de la moyenne en haut à droite
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Moyenne : ${moyenne.toStringAsFixed(1)}",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
