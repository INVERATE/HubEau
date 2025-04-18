class Station {
  final String code;
  final String libelle;
  final double latitude;
  final double longitude;


  Station({
    required this.code,
    required this.libelle,
    required this.latitude,
    required this.longitude,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code_station'] ?? 'Inconnu',
      libelle: json['libelle_station'] ?? 'Sans nom',
      latitude: json['latitude_station']?.toDouble() ?? 0.0,
      longitude: json['longitude_station']?.toDouble() ?? 0.0,
    );
  }
}
