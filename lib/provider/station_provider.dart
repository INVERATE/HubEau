import 'package:flutter/material.dart';
import '../models/station_model.dart';

class StationProvider with ChangeNotifier {
  Station? _selectedStation;

  Station? get selectedStation => _selectedStation;

  void selectStation(Station station) {
    _selectedStation = station;
    notifyListeners(); // tous les widgets abonnés vont se reconstruire
  }
}
