

class Observation {
  final String codeStation;
  final double resultatObs;
  final String grandeurHydro; // "H" ou "Q"
  final DateTime dateObs;
  final String libelleStatut;
  final double latitude;
  final double longitude;

  Observation({
    required this.codeStation,
    required this.resultatObs,
    required this.grandeurHydro,
    required this.dateObs,
    required this.libelleStatut,
    required this.latitude,
    required this.longitude,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      codeStation: json['code_station'] ?? 'N/A',
      resultatObs: (json['resultat_obs'] ?? 0).toDouble(),
      grandeurHydro: json['grandeur_hydro'] ?? 'N/A',
      dateObs: DateTime.parse(json['date_obs'] ?? 'N/A'),
      libelleStatut: json['libelle_statut'] ?? 'N/A',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}