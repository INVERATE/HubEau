import 'package:dio/dio.dart';
import '../models/observation_model.dart'; // Import du modèle
import 'package:dio/dio.dart' as dio_http;

final dio = Dio();

class Post {
  final double longitude;
  final double latitude;

  Post({required this.longitude, required this.latitude});
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }
  Map<String, dynamic> toJson() => {
    'longitude': longitude,
    'latitude': latitude,
  };
}


class HubEauAPILocalisation {
  final String rootPath = 'https://hubeau.eaufrance.fr/api/v2/hydrometrie';
  final dio_http.Dio dio = dio_http.Dio();

  Future<List<Post>> getStationListLong(String dept) async {
    final response = await dio.get(
      '$rootPath/referentiel/stations?code_departement=$dept&format=json&size=20',
    );

    if (response.statusCode == 200) {
      List<dynamic> stationsJson = response.data['data'] ?? [];
      return stationsJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des stations');
    }
  }
}