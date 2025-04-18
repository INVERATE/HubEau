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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: FavoriteScreen(),
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<int> favoriteCards = []; // stocke les cartes par identifiant (ex: ID)
  int _cardId = 0;

  void addFavoriteCard() {
    setState(() {
      favoriteCards.add(_cardId);
      _cardId++;
    });
  }

  void removeFavoriteCard(int id) {
    setState(() {
      favoriteCards.remove(id);
    });
  }

  List<Widget> _buildSpacedCards() {
    List<Widget> spacedCards = [];

    for (int i = 0; i < favoriteCards.length; i++) {
      int cardId = favoriteCards[i];

      spacedCards.add(
        Card(
          color: Colors.blue[200],
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: 150,
            height: 200,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Carte favorite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton.icon(
                  onPressed: () => removeFavoriteCard(cardId),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                  ),
                )
              ],
            ),
          ),
        ),
      );

      if (i < favoriteCards.length - 1) {
        spacedCards.add(const SizedBox(width: 5));
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
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

