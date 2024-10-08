// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/reservation/reservation.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class SelectLocationScreen extends StatefulWidget {
  SelectLocationScreen({super.key, required this.companyId, required this.compName, required this.busnum, required this.currentloc});

  String companyId;
  String compName;
  String busnum;
  LatLng currentloc;

  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? selectedLocation; // Variable to store selected LatLng
  LatLng? location_coordinates;
  late GoogleMapController mapController;
  String address = "";
  final TextEditingController _searchController = TextEditingController(); // Controller for the search input
  bool isLoading = false; // Loading state for search

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(15.9759, 120.5713), // Example coordinates
    zoom: 12,
  );

  // Function to handle map tap and store the selected LatLng
  void _onMapTapped(LatLng position) async {
    setState(() {
      selectedLocation = position;
    });
    String fetchedAddress = await ApiCalls().reverseGeocode(position.latitude, position.longitude);
    print(fetchedAddress);
    setToLocation(position);
    setState(() {
      address = fetchedAddress;
    });
  }

  // Function to search for an address and update the map
  Future<void> _searchLocation() async {
    String searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    LatLng? coordinates = await ApiCalls().getCoordinates(searchText);

    setState(() {
      isLoading = false;
    });

    if (coordinates != null) {
      setToLocation(coordinates);
      _onMapTapped(coordinates);
      
    } else {
      // Handle address not found scenario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address not found")),
      );
    }
  }

  // Method to update the camera position
  void setToLocation(LatLng position) {
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      location_coordinates = position;
    });
    print(location_coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextContent(name: "Select Destination", fcolor: Colors.white),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: _onMapTapped, // Handle tap on map
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: selectedLocation!,
                    ),
                  }
                : {},
          ),
          if (selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 226, 220, 220),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextContent(
                      name: 'Selected Destination',
                      fontsize: 20,
                      fontweight: FontWeight.w700,
                    ),
                    const Spacer(),
                    address.isEmpty
                        ? const CircularProgressIndicator()
                        : TextContent(name: address),
                    const Spacer(),
                    EButtons(
                      onPressed: () {
                        print('Executed');
                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=>SeatReservationScreen(companyId: widget.companyId, companyname: widget.compName, busnum: widget.busnum, mylocation: widget.currentloc, destination: address,destinationcoordinates: location_coordinates!,)));
                      },
                      name: 'Confirm',
                      bcolor: Colors.blueAccent,
                      tcolor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          // Search Bar
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search for a location...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blueAccent),
                      onPressed: _searchLocation, // Call the search function
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
