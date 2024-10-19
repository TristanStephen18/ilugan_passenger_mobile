import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
// import 'package:ilugan_passenger_mobile_app/screens/authentication/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/index/landingscreen2.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/notification.dart';
import 'package:ilugan_passenger_mobile_app/widgets/classes.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
// import 'package:qr_flutter/qr_flutter.dart';

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
    customIconforMovingBuses();
    fetchBusesForCompany();
  }

  LatLng myloc = const LatLng(120.56463553247369, 120.56463553247369);
  String username = "";
  String email = "";

  void fetchBusesForCompany() {
  String companyId = '1CzPhECXc8PFJQP4rfGzwW77gKp1';

  FirebaseFirestore.instance
      .collection('companies')
      .doc(companyId)
      .collection('buses')
      .snapshots()
      .listen((busSnapshot) async {
    for (var busDoc in busSnapshot.docs) {
      // Cast bus data to a Map<String, dynamic>
      var busData = busDoc.data() as Map<String, dynamic>;

      String busNumber = busData['bus_number'] ?? '';
      
      // Skip the bus with number 'BUS 1231'
      if (busNumber == 'BUS 1231') {
        continue; // Skip this iteration
      }

      String plateNumber = busData['plate_number'] ?? '';
      int availableSeats = busData['available_seats'] ?? 0;
      int occupiedSeats = busData['occupied_seats'] ?? 0;
      int reservedSeats = busData['reserved_seats'] ?? 0;
      GeoPoint geoPoint = busData['current_location'] ?? GeoPoint(0, 0);
      GeoPoint detination_geopoint = busData['destination_coordinates'] ?? GeoPoint(0, 0);

      // Convert GeoPoint to LatLng
      LatLng currentLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
      LatLng destination_location = LatLng(geoPoint.latitude, geoPoint.longitude);

      // Reverse geocoding to get address
      String address = await ApiCalls()
          .reverseGeocode(currentLocation.latitude, currentLocation.longitude);

      // Add or update the bus marker on the map
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId(busNumber), // Unique marker ID
            position: currentLocation,
            onTap: () {
              DisplayItems().showbusinfo(
                  context,
                  'Dagupan Bus Inc.', // You may add company name if needed
                  busNumber,
                  plateNumber,
                  address,
                  availableSeats,
                  occupiedSeats,
                  reservedSeats,
                  companyId,
                  myloc,
                  hasreservation,
                  destination_location,
                  currentLocation
                  );
            },
            icon: busmarkers,
          ),
        );
      });
    }
  }, onError: (e) {
    print('Error fetching buses: $e');
  });
}



  bool hasreservation = false;

  void getemailandusername() {
  print("Listening for user data changes");

  String userId = FirebaseAuth.instance.currentUser!.uid;

  FirebaseFirestore.instance
      .collection('passengers')
      .doc(userId)
      .snapshots()
      .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        email = data['email'];
        username = data['username'];
        hasreservation = data['hasreservation'];
      });

      print('Updated email: ${data['email']}');
    } else {
      print("Document does not exist");
    }
  });
}

  BitmapDescriptor busmarkers = BitmapDescriptor.defaultMarker;

  void customIconforMovingBuses() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
        size: Size(2, 2), // Reduce the size here
        devicePixelRatio: 1, // Adjust for better scaling
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
      myloc = LatLng(position.latitude, position.longitude);
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
      MaterialPageRoute(builder: (_) => LandingScreen2()),
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
          title: Row(
            children: [
              TextContent(
                name: 'ILugan',
                fcolor: Colors.white,
              ),
              const Image(
              image: AssetImage("assets/images/logo/logo.png"),
              height: 32,
              width: 32,
            ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_)=>NotificationsPage()));
                },
                icon: const Icon(
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
        // floatingActionButton: FloatingActionButton(onPressed: getCurrentLocation, child: TextContent(name: 'My Location'),),
       ),
    );
  }
}
