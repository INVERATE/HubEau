// Import du modèle
import '../models/observation_model.dart';
import '../models/station_model.dart';
import 'package:dio/dio.dart' as dio_http;



class HubEauAPI {
  final String rootPath = 'https://hubeau.eaufrance.fr/api/v2/hydrometrie';
  final dio_http.Dio dio = dio_http.Dio();

  Future<List<Station>> getStationListByDepartment(String dept) async {
    final url = '$rootPath/referentiel/stations?code_departement=$dept&format=json&size=20';
    print("🔍 Requête vers : $url");

    List<Station> allStations = [];
    String? nextUrl = url; // Commence avec l'URL de la première page

    try {
      while (nextUrl != null) {
        final response = await dio.get(nextUrl);

        print(" Status Code : ${response.statusCode}");
        print(" Corps réponse : ${response.data}");

        if (response.statusCode == 200 || response.statusCode == 206) {
          List<dynamic> stationsJson = response.data['data'] ?? [];
          allStations.addAll(stationsJson.map((json) => Station.fromJson(json)));

          // Vérifie si un lien "next" est présent pour récupérer la page suivante
          nextUrl = response.data['next']; // Cette variable contient l'URL de la page suivante
        } else {
          throw Exception('Erreur ${response.statusCode}: ${response.statusMessage}');
        }
      }
    } catch (e) {
      print(" Erreur sur la requête : $e");
      rethrow;
    }

    print('Nombre total de stations récupérées : ${allStations.length}'); // Debug
    return allStations;
  }



  // Fonction pour récupérer toutes les stations
  Future<List<Station>> getAllStations() async {
    List<Station> allStations = [];
    String? nextUrl = '$rootPath/referentiel/stations';

    int maxPages = 5; // 🛑 Définit un nombre max de pages à récupérer
    int pageCount = 0;

    try {
      while (nextUrl != null && pageCount < maxPages) {
        final response = await dio.get(nextUrl,
          queryParameters: {
          'format': 'json',
          'size': 20,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          // Ajoute les stations
          List<dynamic> stationsJson = response.data['data'] ?? [];
          allStations.addAll(stationsJson.map((json) => Station.fromJson(json)));

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

    print('Nombre total de stations récupérées : ${allStations.length}'); // Debug
    return allStations;
  }

  // Fonction pour récupérer les observations
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