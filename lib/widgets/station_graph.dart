import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import 'package:intl/intl.dart';

class FlowChart extends StatelessWidget {
  final List<Observation> observations;
  final String type; // "Q" ou "H"
  final bool isLoading; // Indique si le chargement des données à partir de l'API est en cours

  // Constructeur
  const FlowChart({
    super.key,
    required this.observations,
    required this.type,
    required this.isLoading
  });

  @override
  Widget build(BuildContext context) {

    // Calcul des données pour le graphique
    final spots = observations.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.resultatObs);
    }).toList();

    // Calcul de la moyenne
    final moyenne = observations.isNotEmpty
        ? (observations.map((e) => e.resultatObs).reduce((a, b) => a + b) / observations.length).toDouble()
        : 0.0;

    // Calcul des labels pour les axes
    final dateLabels = observations.map((obs) {
      return DateFormat('dd/MM').format(obs.dateObs);
    }).toList();
    final dateHourLabels = observations.map((obs) {
      return DateFormat('dd/MM HH:mm').format(obs.dateObs);
    }).toList();

    // Calcul des limites du graphique
    final values = observations.map((e) => e.resultatObs).toList();
    final minVal = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b).toDouble() : 0.0;
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b).toDouble() : 1.0;
    final range = maxVal - minVal;
    final margin = range * 0.05;
    final minY = (minVal - margin).clamp(double.negativeInfinity, double.infinity).toDouble();
    final maxY = maxVal + margin;

    // Definition de la hauteur du widget
    final height = 130.0;


    // Construction du widget en fonction du chargement des données
    Widget content;
    // Si le chargement des données est en cours, affiche un widget de chargement
    if (isLoading) {
      content = SizedBox(
        height: height,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Si aucune donnée n'est disponible, affiche un message
    else if (observations.isEmpty) {
      content = SizedBox(
        height: height,
        child: Center(child: Text("Aucune donnée disponible")),
      );
    }

    // Si les données sont disponibles, affiche le graphique
    else {
      content = LayoutBuilder(
        builder: (context, constraints) {
          // Détermine si le layout est large ou réduit
          final isWideLayout = constraints.maxWidth > 400;

          // Construction du widget en fonction du layout
          if (isWideLayout) {
            return SizedBox(
              height: height,
              child: Row(
                children: [
                  // Statistiques en colonne
                  _buildStatsColumn(type, moyenne, minVal, maxVal, observations),
                  const SizedBox(width: 10),

                  // Graphique
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
                // Statistiques en wrap (layout réduit)
                _buildStatsWrap(type, moyenne, minVal, maxVal, observations),
                SizedBox(height: 16),

                // Graphique
                SizedBox(
                  height: height,
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

    // Construction du widget
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre du widget
            Text(
              type == "Q" ? "Débit" : "Hauteur",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content, // Utilisation du widget content qui changera en fonction du chargement des données
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
    final sign = difference > 0 ? "+" : ""; // Affiche le signe d'une différence
    final unite = type == "Q" ? "L/s" : "mm"; // Définit l'unité en fonction du type

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
    final sign = difference > 0 ? "+" : ""; // Affiche le signe d'une différence
    final unite = type == "Q" ? "L/s" : "mm"; // Définit l'unité en fonction du type

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
        // Ligne en dessous du graphique lorsque l'utilisateur clique sur un point
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) => TouchedSpotIndicatorData(
              FlLine(color: type == "Q" ? Colors.green : Colors.blue, strokeWidth: 2, dashArray: [5, 5]),
              FlDotData(show: true),
            )).toList();
          },

          // Infobulle sur le graphique lorsque l'utilisateur clique sur un point
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black54, // couleur du fond de l'infobulle
            getTooltipItems: (spots) {
              // retourne les données de l'infobulle
              return spots
                  .map((spot) => LineTooltipItem(
                '${dateHourLabels[spot.spotIndex]}\n${spot.y.toStringAsFixed(1)} ${type == "Q" ? "L/s" : "mm"}',
                const TextStyle(color: Colors.white, fontSize: 12),
              )).toList();
            },
          ),
        ),

        // titres des axes
        // Affichage des valeurs sur l'axe y
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // PAS AFFICHE, MAIS POSSIBLE DE L'UTILISER SI BESOIN
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

          // Affichage des dates sur l'axe x
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Affiche les titres
              interval: (observations.length / 5).floorToDouble().clamp(1, double.infinity), // Affiche les titres sur 5 intervalles
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < dateLabels.length-1) {
                  return Text(
                    dateLabels[index],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  );
                }
                // Si l'index est hors limites, retourne un widget vide
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        // bordures et grille
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black26, width: 2)),
        gridData: FlGridData(
          show: true,
          // ligne horizontale
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.black12, strokeWidth: 1);
          },
          // ligne verticale
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.black12, strokeWidth: 1);
          },
        ),

        // données du graphique
        lineBarsData: [
          LineChartBarData(
            spots: spots, // données du graphique
            isCurved: true, // lissage du graphique
            color: type == "Q" ? Colors.green : Colors.blue, // couleur du graphique
            dotData: FlDotData(show: false), // pas de cercles affichés pour chaque point
            belowBarData: BarAreaData(show: false), // pas d'aire sous le graphique
          ),
        ],

        // ligne de la moyenne
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: moyenne, // valeur de la moyenne
            color: Colors.black54,
            dashArray: [5, 5],
            label: HorizontalLineLabel(show: false), // pas de label pour la ligne de la moyenne
          ),
        ]),
      ),
    );
  }
}