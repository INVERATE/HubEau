

class FlowObservation {
  final String codeStation;
  final double resultatObs;
  final String grandeurHydro; // "H" ou "Q"
  final String dateObs;
  final String libelleStatut;

  FlowObservation({
    required this.codeStation,
    required this.resultatObs,
    required this.grandeurHydro,
    required this.dateObs,
    required this.libelleStatut,
  });

  factory FlowObservation.fromJson(Map<String, dynamic> json) {
    return FlowObservation(
      codeStation: json['code_station'] ?? 'N/A',
      resultatObs: (json['resultat_obs'] ?? 0).toDouble(),
      grandeurHydro: json['grandeur_hydro'] ?? 'N/A',
      dateObs: json['date_obs'] ?? 'N/A',
      libelleStatut: json['libelle_statut'] ?? 'N/A',
    );
  }
}



// Séparer les données Hauteur (H) et Débit (Q)
List<FlowObservation> filterByType(List<FlowObservation> observations, String type) {
  return observations.where((obs) => obs.grandeurHydro == type).toList();
}