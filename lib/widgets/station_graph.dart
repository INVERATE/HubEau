import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import 'package:intl/intl.dart';

class FlowChart extends StatelessWidget {
  final List<Observation> observations;
  final String type; // "Q" ou "H"
  final bool isLoading;

  const FlowChart({
    super.key,
    required this.observations,
    required this.type,
    required this.isLoading
  });

  @override
  Widget build(BuildContext context) {
    final spots = observations.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.resultatObs);
    }).toList();

    final moyenne = observations.isNotEmpty
        ? (observations.map((e) => e.resultatObs).reduce((a, b) => a + b) / observations.length).toDouble()
        : 0.0;

    final dateLabels = observations.map((obs) {
      return DateFormat('dd/MM').format(obs.dateObs);
    }).toList();
    final dateHourLabels = observations.map((obs) {
      return DateFormat('dd/MM HH:mm').format(obs.dateObs);
    }).toList();

    final values = observations.map((e) => e.resultatObs).toList();
    final minVal = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b).toDouble() : 0.0;
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b).toDouble() : 1.0;

    final range = maxVal - minVal;
    final margin = range * 0.05;
    final minY = (minVal - margin).clamp(double.negativeInfinity, double.infinity).toDouble();
    final maxY = maxVal + margin;

    Widget content;
    if (isLoading) {
      content = const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (observations.isEmpty) {
      content = const SizedBox(
        height: 150,
        child: Center(child: Text("Aucune donnée disponible")),
      );
    } else {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final isWideLayout = constraints.maxWidth > 400;
          if (isWideLayout) {
            return SizedBox(
              height: 150,
              child: Row(
                children: [
                  _buildStatsColumn(type, moyenne, minVal, maxVal, observations),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildChart(
                      observations,
                      spots,
                      moyenne,
                      minY,
                      maxY,
                      type,
                      dateLabels,
                      dateHourLabels,
                      range,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatsWrap(type, moyenne, minVal, maxVal, observations),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: _buildChart(
                    observations,
                    spots,
                    moyenne,
                    minY,
                    maxY,
                    type,
                    dateLabels,
                    dateHourLabels,
                    range,
                  ),
                ),
              ],
            );
          }
        },
      );
    }

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == "Q" ? "Débit" : "Hauteur",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content, // 👈 on insère ici le bloc correctement construit
          ],
        ),
      ),
    );
  }



  // Statistiques en colonne pour layout large
  Widget _buildStatsColumn(String type, double moyenne, double minVal, double maxVal, List<Observation> observations) {
    final premiereValeur = observations.first.resultatObs;
    final derniereValeur = observations.last.resultatObs;
    final difference = derniereValeur - premiereValeur;
    final sign = difference > 0 ? "+" : "";
    final unite = type == "Q" ? "L/s" : "mm";

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatContainer(
              "Moyenne : ${moyenne.toStringAsFixed(1)} $unite",
              Colors.black
          ),
          const SizedBox(height: 8),
          _buildStatContainer(
              "Min : ${minVal.toStringAsFixed(0)} $unite",
              Colors.black
          ),
          const SizedBox(height: 8),
          _buildStatContainer(
              "Max : ${maxVal.toStringAsFixed(0)} $unite",
              Colors.black
          ),
          const SizedBox(height: 8),
          _buildStatContainer(
              "Diff : $sign${difference.toStringAsFixed(0)} $unite",
              difference > 0 ? Colors.green : difference < 0 ? Colors.orange : Colors.black
          ),
        ],
      ),
    );
  }

  // Statistiques en wrap pour layout étroit
  Widget _buildStatsWrap(String type, double moyenne, double minVal, double maxVal, List<Observation> observations) {
    final premiereValeur = observations.first.resultatObs;
    final derniereValeur = observations.last.resultatObs;
    final difference = derniereValeur - premiereValeur;
    final sign = difference > 0 ? "+" : "";
    final unite = type == "Q" ? "L/s" : "mm";

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatContainer(
            "Moyenne : ${moyenne.toStringAsFixed(1)} $unite",
            Colors.black
        ),
        _buildStatContainer(
            "Min : ${minVal.toStringAsFixed(0)} $unite",
            Colors.black
        ),
        _buildStatContainer(
            "Max : ${maxVal.toStringAsFixed(0)} $unite",
            Colors.black
        ),
        _buildStatContainer(
            "Diff : $sign${difference.toStringAsFixed(0)} $unite",
            difference > 0 ? Colors.green : difference < 0 ? Colors.orange : Colors.black
        ),
      ],
    );
  }

  // Conteneur pour une statistique avec fond arrondi
  Widget _buildStatContainer(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }

  // Widget pour le graphique
  Widget _buildChart(
      List<Observation> observations,
      List<FlSpot> spots,
      double moyenne,
      double minY,
      double maxY,
      String type,
      List<String> dateLabels,
      List<String> dateHourLabels,
      double range
      ) {
    //Graphique
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: observations.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,

        // Infobulle
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) {
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
                '${dateHourLabels[spot.spotIndex]}\n${spot.y.toStringAsFixed(1)} ${type == "Q" ? "L/s" : "mm"}',
                const TextStyle(color: Colors.white, fontSize: 12),
              )).toList();
            },
          ),
        ),

        // titres des axes
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 70,
              interval: (range / 5).clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                if ((value - minY).abs() < 1e-2 || (value - maxY).abs() < 1e-2) {
                  return const SizedBox.shrink();
                }
                return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (observations.length / 5).floorToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < dateLabels.length-1) {
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

        // bordures et grille
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black26, width: 2)),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.black12, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.black12, strokeWidth: 1);
          },
        ),

        // données du graphique
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: type == "Q" ? Colors.green : Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],

        // ligne de la moyenne
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: moyenne,
            color: Colors.black54,
            dashArray: [5, 5],
            label: HorizontalLineLabel(show: false),
          ),
        ]),
      ),
    );
  }
}