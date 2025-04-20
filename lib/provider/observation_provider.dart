import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import '../services/api.dart';

class ObservationProvider extends ChangeNotifier {
  final HubEauAPI _api = HubEauAPI();

  String? _stationId;
  String? _selectedDepartment;
  List<Observation> _observations = [];
  bool _isLoading = false;
  String? _error;

  // === INFORMATIONS PUBLICS ===
  String? get stationId => _stationId;
  String? get selectedDepartment => _selectedDepartment;
  List<Observation> get observations => List.unmodifiable(_observations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Observation> get hauteur => _filteredByType("H");
  List<Observation> get debit => _filteredByType("Q");

  // === MISE À JOUR DE LA STATION ===
  set stationId(String? id) {
    _stationId = id;
    notifyListeners();
  }


  Future<void> selectStation(String stationId, String date) async {
    _stationId = stationId;
    _setLoading(true);
    _error = null;

    try {
      final result = await _api.getFlowByStationAndDate(stationId, date);
      _observations = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // === MISE À JOUR DU DÉPARTEMENT ===
  void selectDepartment(String departmentCode) {
    if (_selectedDepartment == departmentCode) return;
    _selectedDepartment = departmentCode;
    notifyListeners();
  }

  // === FILTRAGE DES OBSERVATIONS SELON LE TYPE (H ou Q) ===
  List<Observation> _filteredByType(String type) {
    final filtered = _observations
        .where((o) => o.grandeurHydro == type)
        .toList()
      ..sort((a, b) => -b.dateObs.compareTo(a.dateObs));
    return filtered;
  }

  // === ÉTAT DE CHARGEMENT DE LA PAGE ===
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
