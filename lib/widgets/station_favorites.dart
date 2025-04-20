import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart';
import '../models/station_model.dart';
import '../services/api.dart';

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

class FavoriteStationsWidget extends StatefulWidget {
  final void Function(String stationCode)? onStationSelected;
  const FavoriteStationsWidget({super.key, this.onStationSelected});

  @override
  State<FavoriteStationsWidget> createState() => _FavoriteStationsWidgetState();
}

class _FavoriteStationsWidgetState extends State<FavoriteStationsWidget> {
  final List<FavoriteCardData> favoriteStations = [];
  final ScrollController _scrollController = ScrollController();

  int offset = 160;

  void addFavoriteCard() {
    final provider = Provider.of<ObservationProvider>(context, listen: false);
    final stationId = provider.stationId;

    final alreadyExists = favoriteStations.any((card) => card.stationId == stationId);

    if (stationId != null && !alreadyExists) {
      final debitList = provider.debit;
      final hauteurList = provider.hauteur;

      final maxDebit = debitList.isNotEmpty
          ? debitList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0;

      final maxHauteur = hauteurList.isNotEmpty
          ? hauteurList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0;

      final newCard = FavoriteCardData(
        stationId: stationId,
        maxDebit: maxDebit,
        maxHauteur: maxHauteur,
      );

      setState(() {
        favoriteStations.add(newCard);
      });

      _scrollController.animateTo(
        _scrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La station est déjà dans les favoris.")),
      );
    }
  }

  void removeFavoriteCard(String stationId) {
    setState(() {
      favoriteStations.removeWhere((card) => card.stationId == stationId);
    });
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Fonction pour récupérer les informations de la station
  Widget _buildFavoriteCard(FavoriteCardData cardData) {
    final maxDebit = cardData.maxDebit;
    final maxHauteur = cardData.maxHauteur;

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
          SnackBar(content: Text('Station sélectionnée : ${cardData.stationId}'), duration: const Duration(seconds: 1),),
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
                ),//fe
              ),
              FutureBuilder<Station>(
                future: HubEauAPI().getStationByCode(cardData.stationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("La connexion avec l'API rencontre actuellement quelques problèmes");
                  } else if (!snapshot.hasData) {
                    return const Text("Aucune donnée disponible");
                  }
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: addFavoriteCard,
            icon: const Icon(Icons.favorite_border),
            label: const Text('Ajouter une station favorite'),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              IconButton(
                onPressed: scrollLeft,
                icon: const Icon(Icons.arrow_back_ios),
              ),
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