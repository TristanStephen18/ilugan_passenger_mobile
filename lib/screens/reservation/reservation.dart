// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/homescreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/reservation/widgets.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:status_alert/status_alert.dart';

class SeatRservationScreen extends StatefulWidget {
  SeatRservationScreen(
      {super.key,
      required this.companyId,
      required this.companyname,
      required this.busnum,
      required this.mylocation});

  String companyId;
  String companyname;
  String busnum;
  LatLng mylocation;

  @override
  State<SeatRservationScreen> createState() => _SeatRservationScreenState();
}

class _SeatRservationScreenState extends State<SeatRservationScreen> {
  @override
  void initState() {
    super.initState();
    print(widget.companyId + widget.companyname + widget.busnum);
    setfields();
    getBusData();
  }

  void setfields() async {
    currentlocc = await ApiCalls()
        .getBarangay(widget.mylocation.latitude, widget.mylocation.longitude);
    setState(() {});
  }

  void getdistance() async {
    distance = await ApiCalls().getDistance(
        LatLng(widget.mylocation.latitude, widget.mylocation.longitude),
        coordinates);
    getamount();
    setState(() {});
  }

  List<String> cities = [
    'Dagupan City',
    'Calasiao',
    'Santa Barbara',
    'Urdaneta City',
    'Paniqui',
    'Gerona',
    'Tarlac City',
    'Dau',
    'Quezon City'
  ];

  Future<void> updateDocument() async {
    await FirebaseFirestore.instance
        .collection('passengers') // Specify the collection
        .doc(FirebaseAuth.instance.currentUser?.uid) // Specify the document ID
        .update({
      'hasreservation': true, // Field you want to update
    }).then((_) {
      print('Document successfully updated!');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }).catchError((error) {
      print('Failed to update document: $error');
    });
  }

  Future<void> updatebusdata (int avail, int occu, int res)async{
    await FirebaseFirestore.instance.collection('companies').doc(widget.companyId).collection('buses').doc(widget.busnum).update({
      'available_seats' : avail - int.parse(seatscon.text),
      'occupied_seats' : occu + int.parse(seatscon.text),
      'reserved_seats' : res + int.parse(seatscon.text)
    }).then((value) {
      print('Bus Data Updated');
    }).catchError((error){
      print('Error updated the bus data');
    });
  }

  String? selectedCity;
  LatLng coordinates = const LatLng(120.09093123, 129.10319823798);
  var currentloccon = TextEditingController();
  String currentlocc = "";
  var discon = TextEditingController();
  var amountcon = TextEditingController();
  var seatscon = TextEditingController();
  DateTime current = DateTime.now();
  String? distance = "...";
  String amount = "...";

  void getcoordinates(String? address) async {
    coordinates = await ApiCalls().getCoordinates(address.toString()) as LatLng;
    print(coordinates);
    setState(() {});
  }

  int occ = 0;
  int reserved = 0;

  void getBusData() {
    FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('buses')
        .doc(widget.busnum)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        print(data['available_seats']);
        setState(() {
          seatsavail = data['available_seats'];
          occ = data['occupied_seats'];
          reserved = data['reserved_seats'];
        });
      } else {
        print('unable to find data');
      }
    });
  }

  void reserve() async {
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('buses')
        .doc(widget.busnum)
        .collection('reservations')
        .get();

    if (snapshots.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('buses')
          .doc(widget.busnum)
          .collection('reservations')
          .doc('1')
          .set({
        'passengerId': FirebaseAuth.instance.currentUser!.uid,
        'amount': double.parse(amount),
        'distance': distance,
        'from': currentlocc,
        'to': selectedCity,
        'date_time': current,
        'seats_reserved': int.parse(seatscon.text),
        'accomplished': false
      }).then((value) {
        print('Reserved');
        updatebusdata(seatsavail, occ, reserved);
        updateDocument();
      }).catchError((error) {
        print('error');
      });
    } else {
      int entries = snapshots.docs.length;
      entries = entries + 1;
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('buses')
          .doc(widget.busnum)
          .collection('reservations')
          .doc(entries.toString())
          .set({
        'passengerId': FirebaseAuth.instance.currentUser!.uid,
        'amount': double.parse(amount),
        'distance': distance,
        'from': currentlocc,
        'to': selectedCity,
        'date_time': current,
        'seats_reserved': int.parse(seatscon.text),
        'accomplished': false
      }).then((value) {
        print('Reserved + 1');
        updatebusdata(seatsavail, occ, reserved);
        updateDocument();
      }).catchError((error) {
        print(error);
      });
    }
  }

  void getamount() {
    if (distance == '...' || distance == null) {
      return;
    } else {
      List<String> km = distance.toString().split(' ');
      double val = double.parse(km[0]);
      amount = (val * 1.25).toString();
      setState(() {});
    }
  }

  int seatsavail = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.sizeOf(context).height - 100,
          width: MediaQuery.sizeOf(context).width - 50,
          // color: Colors.green,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.green),

          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextContent(
                    name: 'Reservation Details',
                    fontsize: 20,
                    fontweight: FontWeight.bold,
                    fcolor: Colors.white,
                  ),
                  const Gap(1),
                  TextContent(
                    name: widget.companyname,
                    fontsize: 18,
                    fontweight: FontWeight.w700,
                    fcolor: Colors.white,
                  ),
                  const Divider(
                    color: Colors.white,
                  ),
                  const Image(
                    image: AssetImage('assets/icons/dagupan_bus.png'),
                    height: 150,
                  ),
                  const Gap(10),
                  TextContent(
                    name: 'Bus Number: ${widget.busnum}',
                    fcolor: Colors.white,
                    fontsize: 20,
                    fontweight: FontWeight.bold,
                  ),
                  TextContent(
                    name: 'Date: $current',
                    fcolor: Colors.white,
                  ),
                  TextContent(
                    name: 'Available Seats: $seatsavail',
                    fcolor: Colors.white,
                    fontsize: 20,
                  ),
                  const Gap(20),
                  TextContent(
                    name: 'From: $currentlocc',
                    fcolor: Colors.white,
                    fontsize: 20,
                    fontweight: FontWeight.bold,
                  ),
                  const Gap(8),
                  const Gap(10),
                  Row(
                    children: [
                      TextContent(
                        name: 'To: ',
                        fcolor: Colors.white,
                        fontweight: FontWeight.bold,
                        fontsize: 17,
                      ),
                      const Gap(60),
                      DropdownButton<String>(
                        elevation: 10,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 20),
                        dropdownColor: const Color.fromARGB(255, 0, 0, 0),
                        focusColor: Colors.white,
                        hint: const Text('Select Location'),
                        value: selectedCity,
                        onChanged: (String? newValue) async {
                          setState(() {
                            selectedCity = newValue;
                          });
                          getcoordinates(selectedCity);
                          getdistance();
                          // getamount();
                          // print(coordinates);
                        },
                        items: cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const Gap(20),
                  TextContent(
                    name: 'Distance to Travel: $distance',
                    fcolor: Colors.white,
                    fontsize: 20,
                  ),
                  TextContent(
                    name: 'Amount: P $amount',
                    fcolor: Colors.white,
                    fontsize: 20,
                  ),
                  const Gap(10),
                  Fields(
                    fcon: seatscon,
                    label: "How many seats do you want to reserve",
                    leading: Icons.chair,
                    type: TextInputType.number,
                  ),
                  const Spacer(),
                  Buttons(
                    onPressed: () {
                      if (seatsavail - (int.parse(seatscon.text)) < 0) {
                        StatusAlert.show(context,
                            title: 'There are only $seatsavail seats available',
                            configuration: const IconConfiguration(
                                icon: Icons.chair_sharp));
                      } else {
                        print('executed');
                        reserve();
                      }
                    },
                    name: 'Reserve',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
