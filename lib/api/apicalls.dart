import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String apiKeyDistance = 'e3NCLlL8P5m5Q3i5vCiFCaHLaoZdMEN1qJ1IK83FxzaBOAYmi8l5dHJXp0qyHzFc';

class ApiCalls {
  Future<String> reverseGeocode(double lat, double lon) async {
  const String apiKey = "pk.e6e28e751bd0e401a2a07cb0cbe2e6e4";
  final String url =
      "https://us1.locationiq.com/v1/reverse.php?key=$apiKey&lat=$lat&lon=$lon&format=json";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name']; // Return the address from the response
    } else {
      return "Address not available";
    }
  } catch (error) {
    print("Error fetching address: $error");
    return "Address not available";
  }
}

Future<String?> getDistance(LatLng origin, LatLng end) async {
  try {
    final response = await http.get(
      Uri.parse(
        'https://api.distancematrix.ai/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${end.latitude},${end.longitude}&key=$apiKeyDistance',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rows'][0]['elements'][0]['distance']['text'];
    } else {
      print('Error fetching distance: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching distance: $error');
    return null;
  }
}



// Function to get estimated time
Future<String?> getEstimatedTime(LatLng origin, LatLng end) async {
  String time= "";
  try {
    final response = await http.get(
      Uri.parse(
        'https://api.distancematrix.ai/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${end.latitude},${end.longitude}&key=$apiKeyDistance',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rows'][0]['elements'][0]['duration']['text'];
    } else {
      print('Error fetching estimated time: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching estimated time: $error');
    return null;
  }
}
}