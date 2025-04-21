// Importation des packages nécessaires
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart'; // Accès au provider des observations pour la station actuelle uniquement
import '../models/station_model.dart'; // Modèle de station
import '../models/observation_model.dart'; // Modèle d'observation (à importer)
import '../services/api.dart'; // API pour récupérer les données des stations

// Modèle représentant une carte de station favorite
class FavoriteCardData {
  final String stationId;
  double lastDebit;
  double meanDebit;
  double lastHauteur;
  double meanHauteur;
  double minThresholdDebit; // Seuil minimum débit
  double maxThresholdDebit; // Seuil maximum débit
  double minThresholdHauteur; // Seuil minimum hauteur
  double maxThresholdHauteur; // Seuil maximum hauteur
  List<Observation> debitObservations = []; // Stocke les observations de débit
  List<Observation> hauteurObservations = []; // Stocke les observations de hauteur
  DateTime lastUpdate = DateTime.now(); // Dernière mise à jour

  FavoriteCardData({
    required this.stationId,
    required this.lastDebit,
    required this.lastHauteur,
    required this.meanDebit,
    required this.meanHauteur,
    this.minThresholdDebit = 0.0,
    this.maxThresholdDebit = 1000.0,
    this.minThresholdHauteur = 0.0,
    this.maxThresholdHauteur = 1000.0,
  });
}

// Widget principal pour afficher les stations favorites
class FavoriteStationsWidget extends StatefulWidget {
  final void Function(String stationCode)? onStationSelected; // Callback lorsqu'une station est sélectionnée
  const FavoriteStationsWidget({super.key, this.onStationSelected});

  @override
  State<FavoriteStationsWidget> createState() => _FavoriteStationsWidgetState();
}

class _FavoriteStationsWidgetState extends State<FavoriteStationsWidget> {
  final List<FavoriteCardData> favoriteStations = []; // Liste des cartes favorites
  final ScrollController _scrollController = ScrollController(); // Contrôle du scroll horizontal
  final Map<String, Station> _stationCache = {}; // Cache des stations déjà chargées
  final HubEauAPI _api = HubEauAPI(); // Instance de l'API

  Timer? _timer; // Timer pour l'API

  int offset = 160; // Distance de scroll horizontal

  @override
  void initState() {
    super.initState();
    // Mise à jour toutes les 5min
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _updateStations());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Mise à jour des stations favorites sans passer par le provider
  void _updateStations() async {
    if (favoriteStations.isEmpty) return;

    for (final card in favoriteStations) {
      try {
        // Récupération des observations directement via l'API
        final fromDate = DateTime.now().subtract(Duration(days: 10));
        final debitObs = await _api.getFlowByStationAndDate(
          card.stationId,
          fromDate.toIso8601String(),
          type: "Q", // Code pour débit
        );

        final hauteurObs = await _api.getFlowByStationAndDate(
          card.stationId,
          fromDate.toIso8601String(),
          type:"H", // Code pour hauteur
        );

        // Mise à jour des données de la carte
        if (debitObs.isNotEmpty || hauteurObs.isNotEmpty) {
          setState(() {
            // Mise à jour des observations stockées
            card.debitObservations = debitObs;
            card.hauteurObservations = hauteurObs;
            card.lastUpdate = DateTime.now();

            // Débit
            if (debitObs.isNotEmpty) {
              card.lastDebit = debitObs.first.resultatObs;
              card.meanDebit = debitObs.map((e) => e.resultatObs).reduce((a, b) => a + b) / debitObs.length;

              // Vérifier si les seuils de débit sont dépassés
              if (card.lastDebit > card.maxThresholdDebit || card.lastDebit < card.minThresholdDebit) {
                _showAlert(
                    "Alerte: Le débit de la station ${card.stationId} est ${card.lastDebit > card.maxThresholdDebit ? 'supérieur au seuil max' : 'inférieur au seuil min'}",
                    card.lastDebit > card.maxThresholdDebit ? Colors.red : Colors.orange
                );
              }
            }

            // Hauteur
            if (hauteurObs.isNotEmpty) {
              card.lastHauteur = hauteurObs.first.resultatObs;
              card.meanHauteur = hauteurObs.map((e) => e.resultatObs).reduce((a, b) => a + b) / hauteurObs.length;

              // Vérifier si les seuils de hauteur sont dépassés
              if (card.lastHauteur > card.maxThresholdHauteur || card.lastHauteur < card.minThresholdHauteur) {
                _showAlert(
                    "Alerte: La hauteur de la station ${card.stationId} est ${card.lastHauteur > card.maxThresholdHauteur ? 'supérieure au seuil max' : 'inférieure au seuil min'}",
                    card.lastHauteur > card.maxThresholdHauteur ? Colors.red : Colors.orange
                );
              }
            }
          });
        }
      } catch (e) {
        debugPrint("Erreur lors de la mise à jour de la station ${card.stationId}: $e");
      }
    }
  }

  // Affiche une alerte via SnackBar
  void _showAlert(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Fonction pour ajouter une station aux favoris
  void addFavoriteCard() async {
    final provider = Provider.of<ObservationProvider>(context, listen: false);
    final stationId = provider.stationId;

    // Vérifie si la station est déjà dans les favoris
    final alreadyExists = favoriteStations.any((card) => card.stationId == stationId);

    if (alreadyExists) {
      // Affiche une alerte si la station est déjà dans les favoris
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La station est déjà dans les favoris.")),
      );
    }
    else if (stationId != null && !alreadyExists) {
      try {
        // Récupération des données directement via l'API
        final fromDate = DateTime.now().subtract(Duration(days: 10));
        final debitObs = await _api.getFlowByStationAndDate(
            stationId,
            fromDate.toIso8601String(),
            type: "Q", // Code pour débit
        );

        final hauteurObs = await _api.getFlowByStationAndDate(
            stationId,
            fromDate.toIso8601String(),
            type:"H", // Code pour hauteur
        );

        // Calcul des valeurs
        double lastDebit = 0.0;
        double meanDebit = 0.0;
        if (debitObs.isNotEmpty) {
          lastDebit = debitObs.first.resultatObs;
          meanDebit = debitObs.map((e) => e.resultatObs).reduce((a, b) => a + b) / debitObs.length;
        }

        double lastHauteur = 0.0;
        double meanHauteur = 0.0;
        if (hauteurObs.isNotEmpty) {
          lastHauteur = hauteurObs.first.resultatObs;
          meanHauteur = hauteurObs.map((e) => e.resultatObs).reduce((a, b) => a + b) / hauteurObs.length;
        }
        print('LastDebit: $lastDebit, MeanDebit: $meanDebit, LastHauteur: $lastHauteur, MeanHauteur: $meanHauteur');

        // Afficher un dialogue pour définir les seuils
        _showThresholdDialog(
          stationId: stationId,
          lastDebit: lastDebit,
          lastHauteur: lastHauteur,
          meanDebit: meanDebit,
          meanHauteur: meanHauteur,
          debitObs: debitObs,
          hauteurObs: hauteurObs,
        );
      } catch (e) {
        debugPrint("Erreur lors de la récupération des données pour ${stationId}: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupération des données: $e")),
        );
      }
    }
  }

  // Dialogue pour configurer les seuils
  void _showThresholdDialog({
    required String stationId,
    required double lastDebit,
    required double lastHauteur,
    required double meanDebit,
    required double meanHauteur,
    required List<Observation> debitObs,
    required List<Observation> hauteurObs,
  }) {
    double minThresholdDebit = 0.0;
    double maxThresholdDebit = 1000.0;
    double minThresholdHauteur = 0.0;
    double maxThresholdHauteur = 1000.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir les seuils'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil minimum (hauteur en mm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minThresholdHauteur = double.tryParse(value) ?? 0.0;
              },
              controller: TextEditingController(text: '0.0'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil maximum (hauteur en mm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxThresholdHauteur = double.tryParse(value) ?? 1000.0;
              },
              controller: TextEditingController(text: '1000.0'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil minimum (débit en L/s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minThresholdDebit = double.tryParse(value) ?? 0.0;
              },
              controller: TextEditingController(text: '0.0'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil maximum (débit en L/s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxThresholdDebit = double.tryParse(value) ?? 1000.0;
              },
              controller: TextEditingController(text: '1000.0'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Création de la carte favorite avec les seuils
              final newCard = FavoriteCardData(
                stationId: stationId,
                lastDebit: lastDebit,
                lastHauteur: lastHauteur,
                meanDebit: meanDebit,
                meanHauteur: meanHauteur,
                minThresholdDebit: minThresholdDebit,
                maxThresholdDebit: maxThresholdDebit,
                minThresholdHauteur: minThresholdHauteur,
                maxThresholdHauteur: maxThresholdHauteur,
              );

              // Stockage des observations
              newCard.debitObservations = debitObs;
              newCard.hauteurObservations = hauteurObs;

              // Ajoute la carte à la liste
              setState(() {
                favoriteStations.add(newCard);
              });

              // Scroll automatique vers la droite après ajout
              _scrollController.animateTo(
                _scrollController.offset + offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Dialogue pour modifier les seuils
  void _editThresholds(FavoriteCardData card) {
    double minThresholdDebit = card.minThresholdDebit;
    double maxThresholdDebit = card.maxThresholdDebit;
    double minThresholdHauteur = card.minThresholdHauteur;
    double maxThresholdHauteur = card.maxThresholdHauteur;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier les seuils'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil minimum (hauteur en mm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minThresholdHauteur = double.tryParse(value) ?? 0.0;
              },
              controller: TextEditingController(text: card.minThresholdHauteur.toString()),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil maximum (hauteur en mm)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxThresholdHauteur = double.tryParse(value) ?? 1000.0;
              },
              controller: TextEditingController(text: card.maxThresholdHauteur.toString()),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil minimum (débit en L/s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minThresholdDebit = double.tryParse(value) ?? 0.0;
              },
              controller: TextEditingController(text: card.minThresholdDebit.toString()),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Seuil maximum (débit en L/s)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxThresholdDebit = double.tryParse(value) ?? 1000.0;
              },
              controller: TextEditingController(text: card.maxThresholdDebit.toString()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                card.minThresholdDebit = minThresholdDebit;
                card.maxThresholdDebit = maxThresholdDebit;
                card.minThresholdHauteur = minThresholdHauteur;
                card.maxThresholdHauteur = maxThresholdHauteur;
              });
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Supprimer une carte favorite
  void removeFavoriteCard(String stationId) {
    setState(() {
      favoriteStations.removeWhere((card) => card.stationId == stationId);
      _stationCache.remove(stationId); // On peut aussi supprimer du cache
    });
  }

  // Scroll vers la gauche
  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Scroll vers la droite
  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Récupère une station depuis l'API ou le cache
  Future<Station> _getStation(String stationId) async {
    if (_stationCache.containsKey(stationId)) {
      return _stationCache[stationId]!;
    }
    final station = await _api.getStationByCode(stationId);
    _stationCache[stationId] = station;
    return station;
  }

  // Détermine la couleur de bordure en fonction des seuils
  Color _getBorderColor(FavoriteCardData cardData) {
    // Débit
    if (cardData.lastDebit > cardData.maxThresholdDebit) {
      return Colors.red;
    } else if (cardData.lastDebit < cardData.minThresholdDebit) {
      return Colors.orange;
    }

    // Hauteur
    if (cardData.lastHauteur > cardData.maxThresholdHauteur) {
      return Colors.red;
    } else if (cardData.lastHauteur < cardData.minThresholdHauteur) {
      return Colors.orange;
    }

    return Colors.grey.shade300; // Couleur par défaut
  }

  // Construction de chaque carte favorite
  Widget _buildFavoriteCard(FavoriteCardData cardData) {
    final double lastDebit = cardData.lastDebit;
    final double lastHauteur = cardData.lastHauteur;
    final double meanDebit = cardData.meanDebit;
    final double meanHauteur = cardData.meanHauteur;

    // Couleur de la bordure en fonction des seuils
    final borderColor = _getBorderColor(cardData);

    // Icônes pour indiquer si la valeur est supérieure ou inférieure à la moyenne
    // Icône débit
    Widget debitIcon;
    if (lastDebit == 0) {
      debitIcon = const Icon(Icons.help_outline, color: Colors.grey, size: 16); // valeur manquante
    } else if (lastDebit > meanDebit) {
      debitIcon = const Icon(Icons.arrow_upward, color: Colors.green, size: 16);
    } else {
      debitIcon = const Icon(Icons.arrow_downward, color: Colors.orange, size: 16);
    }

// Icône hauteur
    Widget hauteurIcon;
    if (lastHauteur == 0) {
      hauteurIcon = const Icon(Icons.help_outline, color: Colors.grey, size: 16); // valeur manquante
    } else if (lastHauteur > meanHauteur) {
      hauteurIcon = const Icon(Icons.arrow_upward, color: Colors.green, size: 16);
    } else {
      hauteurIcon = const Icon(Icons.arrow_downward, color: Colors.orange, size: 16);
    }

    // Formatage de la dernière mise à jour
    final lastUpdateText = 'Mis à jour: ${_formatDateTime(cardData.lastUpdate)}';

    return GestureDetector(
      onTap: () {
        final provider = Provider.of<ObservationProvider>(context, listen: false);
        provider.stationId = cardData.stationId;
        widget.onStationSelected?.call(cardData.stationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Station sélectionnée : ${cardData.stationId}'), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Card(
          elevation: 3,
          margin: EdgeInsets.zero, // Pour que la bordure soit bien visible
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Légèrement plus petit que le container
          ),
          child: Container(
            width: 141,
            height: 200, // Un peu plus grande pour contenir les nouvelles informations
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Boutons pour supprimer la carte et éditer les seuils
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => removeFavoriteCard(cardData.stationId),
                      icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                      tooltip: 'Supprimer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Enlève le padding par défaut
                    ),
                    IconButton(
                      onPressed: () => _editThresholds(cardData),
                      icon: const Icon(Icons.settings, size: 16),
                      tooltip: 'Modifier les seuils',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Enlève le padding par défaut
                    ),
                  ],
                ),

                // Récupération asynchrone des infos de la station

                FutureBuilder<Station>(
                  future: _getStation(cardData.stationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Loading
                    } else if (snapshot.hasError) {
                      return const Text("Erreur de connexion à l'API"); // Erreur
                    } else if (!snapshot.hasData) {
                      return const Text("Aucune donnée disponible"); // Aucune donnée
                    }

                    // Affiche les infos de la station
                    final station = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          station.libelle,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Code : ${station.code}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),

                // Données d'observation avec icônes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hauteur:',
                      style: TextStyle(fontSize: 12),
                    ),


                    Row(
                      children: [
                        Text(
                          '${lastHauteur.toStringAsFixed(0)} mm',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        hauteurIcon,
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Débit:',
                      style: TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          '${lastDebit.toStringAsFixed(0)} L/s',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        debitIcon,
                      ],
                    ),
                  ],
                ),

                // Seuils et dernière mise à jour
                Divider(height: 8, color: Colors.grey.shade300),
                Text(
                  lastUpdateText,
                  style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Formatage de la date et heure
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Construction de l'interface
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // Bouton pour ajouter une station favorite
          ElevatedButton.icon(
            onPressed: addFavoriteCard,
            icon: const Icon(Icons.favorite_border),
            label: const Text('Ajouter une station favorite'),
          ),
          const SizedBox(height: 10),

          // Zone de scroll horizontal avec flèches
          favoriteStations.isEmpty
              ? const Center(
            child: Text('Aucune station favorite. Ajoutez-en une en cliquant sur le bouton ci-dessus.'),
          )
              :
          Row(
            children: [
              // Flèche gauche (compacte)
              SizedBox(
                width: 10, // réduit la largeur, ajuste selon besoin
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: scrollLeft,
                  icon: const Icon(Icons.arrow_back_ios, size: 16), // petite icône
                ),
              ),

              // Liste des cartes favorites
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  height: 215,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: favoriteStations
                          .map((cardData) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: _buildFavoriteCard(cardData),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),

              // Flèche droite (compacte)
              SizedBox(
                width: 10, // réduit la largeur
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: scrollRight,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}