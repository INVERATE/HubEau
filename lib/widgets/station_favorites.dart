import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/observation_provider.dart';

class FavoriteStationsWidget extends StatefulWidget {
  const FavoriteStationsWidget({super.key});

  @override
  State<FavoriteStationsWidget> createState() => _FavoriteStationsWidgetState();
}

class _FavoriteStationsWidgetState extends State<FavoriteStationsWidget> {
  final List<String> favoriteStations = [];
  final ScrollController _scrollController = ScrollController();

  int offset = 160;

  void addFavoriteCard() {
    final provider = Provider.of<ObservationProvider>(context, listen: false);
    final stationId = provider.stationId;

    if (stationId != null && !favoriteStations.contains(stationId)) {
      setState(() {
        favoriteStations.add(stationId);
      });
      _scrollController.animateTo(
        _scrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Afficher un SnackBar si la carte existe déjà
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La station est déjà dans les favoris.")),
      );
    }
  }


  void removeFavoriteCard(String id) {
    setState(() {
      favoriteStations.remove(id);
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

  Widget _buildFavoriteCard(String stationId) {
    final provider = Provider.of<ObservationProvider>(context);
    final debitList = provider.debit;
    final hauteurList = provider.hauteur;

    // Trouver les max
    double maxDebit = debitList.isNotEmpty
        ? debitList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxHauteur = hauteurList.isNotEmpty
        ? hauteurList.map((e) => e.resultatObs).reduce((a, b) => a > b ? a : b)
        : 0;

    // Déterminer la couleur selon le débit
    Color backgroundColor;
    if (maxDebit > 1000) {
      backgroundColor = Colors.redAccent.shade100;
    } else if (maxDebit > 500) {
      backgroundColor = Colors.orangeAccent.shade100;
    } else {
      backgroundColor = Colors.grey.shade300;
    }

    return Card(
      color: backgroundColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        height: 200,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Station favorite $stationId',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Hauteur max: ${maxHauteur.toStringAsFixed(0)} mm',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
            Text(
              'Débit max: ${maxDebit.toStringAsFixed(0)} L/s',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
            ElevatedButton.icon(
              onPressed: () => removeFavoriteCard(stationId),
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
          ],
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
                          .map((stationId) =>
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildFavoriteCard(stationId),
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
