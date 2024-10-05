import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/notification.dart';
import 'package:ilugan_passenger_mobile_app/widgets/classes.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      String plateNumber = busData['plate_number'] ?? '';
      int availableSeats = busData['available_seats'] ?? 0;
      int occupiedSeats = busData['occupied_seats'] ?? 0;
      int reservedSeats = busData['reserved_seats'] ?? 0;
      GeoPoint geoPoint = busData['current_location'] ?? GeoPoint(0, 0);

      // Convert GeoPoint to LatLng
      LatLng currentLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

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
                  'Company Name', // You may add company name if needed
                  busNumber,
                  plateNumber,
                  address,
                  availableSeats,
                  occupiedSeats,
                  reservedSeats,
                  companyId,
                  myloc,
                  hasreservation);
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

  void showQr() {
  print('clicked');
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Reservation Ticket'),
        content: SizedBox(
          height: 200,  // Set a fixed height for the QR container
          width: 200,   // Set a fixed width for the QR container
          child: QrImageView(
            size: 150,  // Set the size of the QR code inside
            data: FirebaseAuth.instance.currentUser!.uid.toString(),
          ),
        ),
      );
    },
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
          backgroundColor: const Color.fromARGB(255, 226, 46, 46),
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Visibility(
            visible: hasreservation,
              child: SizedBox(
                height: 100,
                width:  100,
                  child: FloatingActionButton(
            onPressed: showQr,
            child: const Icon(Icons.qr_code, size: 90,),
          ))),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
