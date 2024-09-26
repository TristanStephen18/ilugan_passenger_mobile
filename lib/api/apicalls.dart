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

 Future<LatLng?> getCoordinates(String address) async {
  const String apiKey = "pk.e6e28e751bd0e401a2a07cb0cbe2e6e4";
  final String encodedAddress = Uri.encodeComponent(address);
  LatLng? coordinates;

  final String url =
      "https://us1.locationiq.com/v1/search?key=${apiKey}&q=${encodedAddress}&format=json";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the first result in the array
      if (data is List && data.isNotEmpty) {
        final firstResult = data[0];
        coordinates = LatLng(
          double.parse(firstResult['lat']),
          double.parse(firstResult['lon']),
        );
        return coordinates;
      } else {
        print("No results found for the address.");
        return null;
      }
    } else {
      print("Error: Received status code ${response.statusCode}");
      return null;
    }
  } catch (error) {
    print("Error fetching address: $error");
    return null;
  }
}


// https://us1.locationiq.com/v1/search?key=Your_API_Access_Token&q=221b%2C%20Baker%20St%2C%20London%20&format=json&

Future<String> getBarangay(double lat, double lon) async {
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

Future<String?> getCityCode(String cityName) async {
  final url = Uri.parse('https://psgc.cloud/api/city');

  try {
    // Make the HTTP GET request
    final response = await http.get(url);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> cities = jsonDecode(response.body);

      // Find the city by name (case-insensitive)
      var city = cities.firstWhere(
          (c) => c['name'].toString().toLowerCase() == cityName.toLowerCase(),
          orElse: () => null);

      // If city found, return the PSGC code
      if (city != null) {
        print('PSGC code for $cityName: ${city['code']}');
        return city['code'].toString();
      } else {
        print('City not found.');
        return null;
      }
    } else {
      print('Failed to load cities');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
}