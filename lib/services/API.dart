import '../models/station_model.dart'; // Import du modèle
import 'package:dio/dio.dart' as dio_http;


// Modèle pour une station
class Station {
  final String code;
  final String libelle;

  Station({required this.code, required this.libelle});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code_station'] ?? 'Inconnu',
      libelle: json['libelle_station'] ?? 'Sans nom',
    );
  }
}


class HubEau_API {
  final String rootPath = 'https://hubeau.eaufrance.fr/api/v2/hydrometrie';
  final dio_http.Dio dio = dio_http.Dio();

  Future<List<Station>> getStationListByDepartment(String dept) async {
    final response = await dio.get(
      '$rootPath/referentiel/stations?code_departement=$dept&format=json&size=20',
    );

    if (response.statusCode == 200) {
      List<dynamic> stationsJson = response.data['data'] ?? [];
      return stationsJson.map((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des stations');
    }
  }

  Future<List<Observation>> getFlowByStationAndDate(String stationCode, String date) async {
    List<Observation> allObservations = [];
    String? nextUrl = '$rootPath/observations_tr?format=json&code_entite=$stationCode&date_debut_obs=$date&size=500';

    int maxPages = 5; // 🛑 Définit un nombre max de pages à récupérer
    int pageCount = 0;

    try {
      while (nextUrl != null && pageCount < maxPages) {
        final response = await dio.get(nextUrl);

        if (response.statusCode == 200 || response.statusCode == 206) {
          // Ajoute les nouvelles observations
          List<dynamic> observationsJson = response.data['data'] ?? [];
          allObservations.addAll(observationsJson.map((json) => Observation.fromJson(json)));

          // Vérifie si un lien "next" est disponible
          nextUrl = response.data['next'];
          pageCount++; // 🛑 Incrémente le nombre de pages récupérées
        } else {
          throw Exception('Erreur ${response.statusCode} : ${response.statusMessage}');
        }
      }
    } catch (e) {
      throw Exception('Requête échouée : $nextUrl \nErreur: $e');
    }

    print('Nombre total d\'observations récupérées : ${allObservations.length}'); // Debug
    return allObservations;
  }
}