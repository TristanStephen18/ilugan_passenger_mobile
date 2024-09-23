import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/screens/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    listenToBusUpdates();
  }

  void listenToBusUpdates() {
    print('Executed');
    FirebaseFirestore.instance
        .collection('companies')
        .snapshots()
        .listen((companySnapshot) {
      for (var companyDoc in companySnapshot.docs) {
        String companyId = companyDoc.id;

        FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('buses')
            .snapshots()
            .listen((busSnapshot) {
          markers.removeWhere(
              (marker) => marker.markerId.value != 'user_location');

          for (var busDoc in busSnapshot.docs) {
            var busData = busDoc.data() as Map<String, dynamic>;

            String busNumber = busData['bus_number'] ?? '';
            String plateNumber = busData['plate_number'] ?? '';
            int availableSeats = busData['available_seats'] ?? 0;
            GeoPoint geoPoint = busData['current_location'] ?? GeoPoint(0, 0);

            LatLng currentLocation =
                LatLng(geoPoint.latitude, geoPoint.longitude);
            print('Bus data: $busData');
            print(
                'Adding marker for bus: $busNumber at location: ${currentLocation.latitude}}');

            setState(() {
              markers.add(
                Marker(
                  markerId: MarkerId(busNumber),
                  position: currentLocation,
                  infoWindow: InfoWindow(
                    title: 'Bus: $busNumber',
                    snippet: 'Available seats: $availableSeats',
                  ),
                  icon: BitmapDescriptor.defaultMarker,
                ),
              );
            });
          }
        });
      }
    });
  }

  void addtomarkers() {}

  Set<Marker> markers = {};

  void getCurrentLocation() async {
    if (!await checkServicePermission()) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((position) {
      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      markers.removeWhere((marker) => marker.markerId.value == 'user_location');
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: currentPosition,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      setToLocation(currentPosition);
    });
  }

  void setToLocation(LatLng position) {
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  Future<bool> checkServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permission permanently denied.')),
      );
      return false;
    }
    return true;
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: AppDrawer(
          username: 'Sample',
          email: 'sampleemail@gmail.com',
        ),
        appBar: AppBar(
          title: TextContent(
            name: 'Homepage',
            fcolor: Colors.white,
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white,
                ))
          ],
        ),
        body: SafeArea(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
                target: LatLng(15.975949534874196, 120.57135500752592),
                zoom: 15),
            mapType: MapType.normal,
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: markers,
          ),
        ),
      ),
    );
  }
}
