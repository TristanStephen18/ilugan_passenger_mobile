import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String apiKeyDistance = 'plpzSXk6wsl0A0OsQxHT4VUJLvCQUHaOaYRuqsieIdc5pswMo6aIeSm5r6eHyynp';

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
  // String time= "";
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

Future<String?> createPayMongoPaymentLink(double amount) async {
  // Replace with your actual API key
  // sString authorizationKey = 'Basic c2tfdGVzdF9YVmZ1c0ZMeldMZ1c3TXFGS3g5RGgyRks6';

  final url = Uri.parse('https://api.paymongo.com/v1/links');

  final headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
    'authorization': 'Basic c2tfdGVzdF9YVmZ1c0ZMeldMZ1c3TXFGS3g5RGgyRks6',
  };

  final body = json.encode({
    "data": {
      "attributes": {
        "amount": (amount * 1000), // Amount in centavos
        "description": "Fare Payment",
        "remarks": 'none',
      }
    }
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final paymentLink = responseData['data']['attributes']['checkout_url'];
      final paymentid = responseData['data']['id'];
      
      print(paymentLink + " " + paymentid );
      return paymentLink + " " + paymentid;
    } else {
      print('Failed to create payment link: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error creating payment link: $error');
    return null;
  }
}

Future<String?> checkpaymentstatus(String paymentId) async {
   try {
        final response = await http.get(
          Uri.parse("https://api.paymongo.com/v1/links/$paymentId"),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Basic c2tfdGVzdF9YVmZ1c0ZMeldMZ1c3TXFGS3g5RGgyRks6',
          },
        );

        if (response.statusCode == 200) {
          final statusData = json.decode(response.body);
          String status = statusData["data"]["attributes"]["status"];
          print(status);
          if (status == "paid") {
            return status;
          }
        } else {
          throw Exception("Failed to fetch payment status.");
        }
      } catch (e) {
        print("Error checking payment status: $e");
      }
}

Future<String> fetchPolyline(LatLng origin, LatLng destination) async {
  // Define the HERE API key
  const String apiKey = 'JS01D6eK9YAqYsGFnKkzT6mYhyWu_hLL3XdkDRSSswM';

  // Build the HERE API URL with the origin and destination
  final String url =
      'https://router.hereapi.com/v8/routes?transportMode=car&return=polyline,summary&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&via=52.52426,13.43000&apiKey=$apiKey';

  // Send the GET request
  final response = await http.get(Uri.parse(url));

  // Check if the request was successful
  if (response.statusCode == 200) {
    // Parse the JSON response
    final Map<String, dynamic> data = json.decode(response.body);

    // Extract the polyline string from the response
    String polyline = data['routes'][0]['sections'][0]['polyline'];
    return polyline;
  } else {
    throw Exception('Failed to fetch polyline');
  }
}

}