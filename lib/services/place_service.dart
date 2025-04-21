import 'dart:convert';
import 'package:http/http.dart' as http;
class PlaceService {
  // clé de l'api google maps
  static const String _apiKey = "AIzaSyCyBxrN4LRkSI-vIKEKi4_2MraPeY4Zjxw";

  /// Fetch place information based on latitude and longitude
  static Future<String> getPlaceFromCoordinates(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          final results = data["results"];
          if (results.isNotEmpty) {
            return results[0]["formatted_address"];
          } else {
            return "No results found";
          }
        } else {
          return "Error: ${data["status"]}";
        }
      } else {
        return "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}