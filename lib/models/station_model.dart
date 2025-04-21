// Permet de mettre en forme les données de l'API pour les stations

class Station {
  final String code;
  final String codeCommune;
  final String libelle;
  final double latitude;
  final double longitude;
  final String? commentaire;
  final bool enService;


  Station({
    required this.code,
    required this.codeCommune,
    required this.libelle,
    required this.latitude,
    required this.longitude,
    this.commentaire,
    required this.enService,
  });


  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code_station'] ?? 'Inconnu',
      codeCommune: json['code_commune_station'] ?? 'Inconnu',
      libelle: json['libelle_station'] ?? 'Sans nom',
      latitude: json['latitude_station']?.toDouble() ?? 0.0,
      longitude: json['longitude_station']?.toDouble() ?? 0.0,
      commentaire: json['commentaire_station'],
      enService: json['en_service'],
    );
  }
}
