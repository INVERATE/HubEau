import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Favorite Cards',
      home: FavoriteScreen(),
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Widget> favoriteCards = [];

  void addFavoriteCard() {
    setState(() {
      favoriteCards.add(
        Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: 150,
            height: 200,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Nouvelle carte favorite',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    });
  }
  List<Widget> _buildSpacedCards() {
    List<Widget> spacedCards = [];
    for (int i = 0; i < favoriteCards.length; i++) {
      spacedCards.add(favoriteCards[i]);
      if (i < favoriteCards.length ) {
        spacedCards.add(const SizedBox(width: 10)); // espace entre les cartes
      }
    }
    return spacedCards;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris dynamiques')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: addFavoriteCard,
                icon: const Icon(Icons.favorite_border),
                label: const Text('Stations favorites'),
              ),
              const SizedBox(height: 15),
              Container(
                  padding: const EdgeInsets.all(10),
                  width: 500,
                  height: 210,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildSpacedCards(),
                  ),

                )
              )
            ],
          ),
        ),
      ),
    );
  }

}
