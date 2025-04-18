import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/provider.dart';
import 'dashboard.dart';
import '../widgets/test_widget.dart';

import '../widgets/maps_stations.dart';


void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObservationProvider()..selectStation("O005002001", "2025-04-12"),
      child: MaterialApp(
        title: 'HubEau Stations',
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
        home: const MyHomePage(),
      ),
    );
  }
}

