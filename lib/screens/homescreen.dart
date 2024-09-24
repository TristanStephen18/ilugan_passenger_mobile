import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/classes.dart';
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
    getemailandusername();
    getCurrentLocation();
    // listenToBusUpdates();
    customIconforMovingBuses();
    fetchAllBuses();
  }

  String username = "";
  String email = "";

  void fetchAllBuses() async {
    try {
      // Step 1: Get all companies
      QuerySnapshot companySnapshot =
          await FirebaseFirestore.instance.collection('companies').get();

      // Step 2: Loop through each company and get its buses
      for (var companyDoc in companySnapshot.docs) {
        String companyId = companyDoc.id;

        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .get();
        var data = snapshot.data() as Map<String, dynamic>;

        String companyname = data['company_name'];
        // Step 3: Fetch buses from each company's buses sub-collection
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('buses')
            .get();

        for (var busDoc in busSnapshot.docs) {
          // Cast bus data to a Map<String, dynamic>
          var busData = busDoc.data() as Map<String, dynamic>;

          String busNumber = busData['bus_number'] ?? '';
          String plateNumber = busData['plate_number'] ?? '';
          int availableSeats = busData['available_seats'] ?? 0;
          int occupiedSeats = busData['occupied_seats'] ?? 0;
          int reservedSeats = busData['reserved_seats'] ?? 0;
          GeoPoint geoPoint = busData['current_location'] ?? GeoPoint(0, 0);

          // Convert GeoPoint to LatLng
          LatLng currentLocation =
              LatLng(geoPoint.latitude, geoPoint.longitude);

          String address = await ApiCalls().reverseGeocode(
              currentLocation.latitude, currentLocation.longitude) as String;

          // Add the bus marker to the map
          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId(busNumber), // Unique ID for each bus
                position: currentLocation,
                // infoWindow: InfoWindow(
                //   title: 'Bus: $busNumber',
                //   snippet: 'Company Name: $companyname',
                // ),
                onTap: () {
                  DisplayItems().showbusinfo(context, companyname, busNumber,
                      address, availableSeats, occupiedSeats, reservedSeats);
                },
                icon: busmarkers,
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error fetching buses: $e');
    }
  }

  void getemailandusername() async {
    print("getusername");
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('passengers')
        .doc(userId)
        .get();
    var data = snapshot.data() as Map<String, dynamic>;

    print(data['email']);

    setState(() {
      email = data['email'];
      username = data['username'];
    });
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

  BitmapDescriptor busmarkers = BitmapDescriptor.defaultMarker;

  void customIconforMovingBuses() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(2, 2), // Reduce the size here
        devicePixelRatio: 2.5, // Adjust for better scaling
      ),
      "assets/icons/moving_bus_icon.png",
    ).then((icon) {
      setState(() {
        busmarkers = icon;
      });
      // print(movingbusMarker.toString());
    }).catchError((error) {
      print("Error loading custom icon: $error");
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
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 13);
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
          logoutfunc: logout,
          username: username,
          email: email,
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
