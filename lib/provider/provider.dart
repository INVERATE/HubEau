// lib/providers/station_provider.dart

import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import '../services/API.dart';

class ObservationProvider extends ChangeNotifier {
  final _api = HubEauAPI();

  String? _stationId;
  List<Observation> _observations = [];
  bool _isLoading = false;
  String? _error;

  String? get stationId => _stationId;
  List<Observation> get observations => _observations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Observation> get hauteur => _filterByType("H");
  List<Observation> get debit => _filterByType("Q");

  Future<void> selectStation(String stationId, String date) async {
    _stationId = stationId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _observations = await _api.getFlowByStationAndDate(stationId, date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour filtrer les observations par type H / Q
  // renvoie une liste d'observations triées par date et par heure en ordre décroissant
  List<Observation> _filterByType(String type) {
    _observations.sort((a, b) {
      if (a.dateObs.isBefore(b.dateObs)) {
        return -1;
      } else if (a.dateObs.isAfter(b.dateObs)) {
        return 1;
      } else {
        return b.dateObs.hour.compareTo(a.dateObs.hour);
      }
    });
    return _observations.where((o) => o.grandeurHydro == type).toList();
  }
}
