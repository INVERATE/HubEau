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
        scaffoldBackgroundColor: Colors.blue[200], // fond doux bleu
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue, // barre du haut bleue
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue, // bouton bleu
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
  List<Widget> favoriteCards = [];

  void addFavoriteCard() {
    setState(() {
      favoriteCards.add(
        Card(
          color: Colors.yellow[800],
          //color: Colors.yellowAccent[300],
          //color: Colors.blue[200],
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // texte blanc pour contraste
                ),
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
      if (i < favoriteCards.length - 1) {
        spacedCards.add(const SizedBox(width: 10)); // espace entre cartes
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
