import 'package:flutter/material.dart';

class FavoriteStationsWidget extends StatefulWidget {
  const FavoriteStationsWidget({super.key});

  @override
  State<FavoriteStationsWidget> createState() => _FavoriteStationsWidgetState();
}

class _FavoriteStationsWidgetState extends State<FavoriteStationsWidget> {
  final List<int> favoriteCards = [];
  final ScrollController _scrollController = ScrollController();
  int _cardId = 0;
  int offset = 160;

  void addFavoriteCard() {
    setState(() {
      favoriteCards.add(_cardId++);
    });
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void removeFavoriteCard(int id) {
    setState(() {
      favoriteCards.remove(id);
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

  Widget _buildFavoriteCard(int cardId) {
    return Card(
      color: Colors.grey[300],
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
              "Carte favorite $cardId",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "Description de la carte favorite $cardId",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => removeFavoriteCard(cardId),
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
                      children: favoriteCards
                          .map((id) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFavoriteCard(id),
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
