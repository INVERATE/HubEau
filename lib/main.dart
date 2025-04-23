import 'package:flutter/material.dart';
import 'package:test_flutter_api/layout/colors.dart';
import 'layout/dashboard.dart';
import 'dart:ui' as ui;


void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HubEau Stations',
      theme: ThemeData(
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: BluePalette.accent,
          margin: EdgeInsets.all(12),
        ),

        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: BluePalette.accent,
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: BluePalette.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: BluePalette.background,

        appBarTheme: const AppBarTheme(
          backgroundColor: BluePalette.primary,
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ),

      home: const MyHomePage(),
    );
  }
}

