import '../models/observation_model.dart';
import '../models/station_model.dart';
import 'package:dio/dio.dart' as dio_http;

class HubEauAPI {
  final String rootPath = 'https://hubeau.eaufrance.fr/api/v2/hydrometrie';
  final dio_http.Dio dio = dio_http.Dio();

  // Méthode générique de pagination pour n'importe quel type de donnée
  Future<List<T>> _paginate<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    int maxPages = 10,
  }) async {
    List<T> results = [];
    String? nextUrl;
    int pageCount = 0;

    try {
      do {
        final response = await dio.get(
          nextUrl ?? url,
          queryParameters: nextUrl == null ? queryParameters : null,
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          List<dynamic> data = response.data['data'] ?? [];
          results.addAll(data.map((json) => fromJson(json)));

          nextUrl = response.data['next'];
          pageCount++;
        } else {
          throw Exception('Erreur ${response.statusCode} : ${response.statusMessage}');
        }
      } while (nextUrl != null && pageCount < maxPages);
    } catch (e) {
      throw Exception('Erreur lors de la pagination de $url : $e');
    }

    return results;
  }

  // Stations : toutes ou par département
  Future<List<Station>> getStations({String? department, int maxPages = 10, bool? enService}) {
    final url = '$rootPath/referentiel/stations';
    final query = {
      'format': 'json',
      'size': 1000,
      if (department != null) 'code_departement': department,
      if (enService != null) 'en_service': enService ? 1 : 0,
    };

    return _paginate<Station>(
      url: url,
      queryParameters: query,
      fromJson: (json) => Station.fromJson(json),
      maxPages: maxPages,
    );
  }

  // Observations : par station et date
  Future<List<Observation>> getFlowByStationAndDate(
      String stationCode,
      String date, {
        int maxPages = 5,
      }) {
    final url = '$rootPath/observations_tr';
    final query = {
      'format': 'json',
      'code_entite': stationCode,
      'date_debut_obs': date,
      'size': 1000,
    };

    return _paginate<Observation>(
      url: url,
      queryParameters: query,
      fromJson: (json) => Observation.fromJson(json),
      maxPages: maxPages,
    );
  }

  // Informations d'une station à partir de son code
  Future<Station> getStationByCode(String stationCode, {int maxPages = 1}) async {
    final url = '$rootPath/referentiel/stations';
    final query = {
      'format': 'json',
      'size': 1,
      'code_station': stationCode,
    };

    return _paginate<Station>(
      url: url,
      queryParameters: query,
      fromJson: (json) => Station.fromJson(json),
      maxPages: maxPages,
    ).then((stations) => stations.first);

  }
}
