// Importation des packages nécessaires
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart'; // Accès au provider des observations
import '../models/station_model.dart'; // Modèle de station
import '../services/api.dart'; // API pour récupérer les données des stations

// Modèle représentant une carte de station favorite
class FavoriteCardData {
  final String stationId;
  final double maxDebit;
  final double maxHauteur;

  FavoriteCardData({
    required this.stationId,
    required this.maxDebit,
    required this.maxHauteur,
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
  final Map<String, Station> _stationCache = {}; // ✅ Cache des stations déjà chargées

  int offset = 160; // Distance de scroll horizontal

  // Fonction pour ajouter une station aux favoris
  void addFavoriteCard() {
    final provider = Provider.of<ObservationProvider>(context, listen: false);
    final stationId = provider.stationId;

    // Vérifie si la station est déjà dans les favoris
    final alreadyExists = favoriteStations.any((card) => card.stationId == stationId);

    if (stationId != null && !alreadyExists) {
      // Récupère les listes de données
      final debitList = provider.debit;
      final hauteurList = provider.hauteur;

      // Calcule le débit maximal
      final maxDebit = debitList.isNotEmpty
          ? debitList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0;

      // Calcule la hauteur maximale
      final maxHauteur = hauteurList.isNotEmpty
          ? hauteurList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0;

      // Création de la carte favorite
      final newCard = FavoriteCardData(
        stationId: stationId,
        maxDebit: maxDebit,
        maxHauteur: maxHauteur,
      );

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
    } else {
      // Affiche une alerte si la station est déjà dans les favoris
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La station est déjà dans les favoris.")),
      );
    }
  }

  // Supprimer une carte favorite
  void removeFavoriteCard(String stationId) {
    setState(() {
      favoriteStations.removeWhere((card) => card.stationId == stationId);
      _stationCache.remove(stationId); // ❌ On peut aussi supprimer du cache
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

  // ✅ Récupère une station depuis l'API ou le cache
  Future<Station> _getStation(String stationId) async {
    if (_stationCache.containsKey(stationId)) {
      return _stationCache[stationId]!;
    }
    final station = await HubEauAPI().getStationByCode(stationId);
    _stationCache[stationId] = station;
    return station;
  }

  // Construction de chaque carte favorite
  Widget _buildFavoriteCard(FavoriteCardData cardData) {
    final maxDebit = cardData.maxDebit;
    final maxHauteur = cardData.maxHauteur;

    // Détermine la couleur selon le débit
    Color backgroundColor;
    if (maxDebit > 1000) {
      backgroundColor = Colors.redAccent.shade100;
    } else if (maxDebit > 500) {
      backgroundColor = Colors.orangeAccent.shade100;
    } else {
      backgroundColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () {
        final provider = Provider.of<ObservationProvider>(context, listen: false);
        provider.stationId = cardData.stationId;
        widget.onStationSelected?.call(cardData.stationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Station sélectionnée : ${cardData.stationId}'), duration: const Duration(seconds: 1)),
        );
      },
      child: Card(
        color: backgroundColor,
        elevation: 5,
        child: Container(
          width: 150,
          height: 220,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton pour supprimer la carte
              ElevatedButton.icon(
                onPressed: () => removeFavoriteCard(cardData.stationId),
                icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(40),
                ),
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
                        'Nom : ${station.libelle}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Code : ${station.code}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              ),

              // Données d'observation
              Text(
                'Hauteur max: ${maxHauteur.toStringAsFixed(0)} mm',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Débit max: ${maxDebit.toStringAsFixed(0)} L/s',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Libération du scrollController à la destruction du widget
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Construction de l'interface
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Bouton pour ajouter une station favorite
          ElevatedButton.icon(
            onPressed: addFavoriteCard,
            icon: const Icon(Icons.favorite_border),
            label: const Text('Ajouter une station favorite'),
          ),
          const SizedBox(height: 15),

          // Zone de scroll horizontal avec flèches
          Row(
            children: [
              // Flèche gauche
              IconButton(
                onPressed: scrollLeft,
                icon: const Icon(Icons.arrow_back_ios),
              ),

              // Liste des cartes favorites
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  height: 230,
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
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFavoriteCard(cardData),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),

              // Flèche droite
              IconButton(
                onPressed: scrollRight,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
