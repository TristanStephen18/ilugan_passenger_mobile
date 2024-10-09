// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/reservation/widgets.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/homescreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:quickalert/quickalert.dart';
import 'package:status_alert/status_alert.dart';

class SeatReservationScreen extends StatefulWidget {
  SeatReservationScreen(
      {super.key,
      required this.companyId,
      required this.companyname,
      required this.busnum,
      required this.mylocation,
      required this.destination,
      required this.destinationcoordinates});

  String companyId;
  String companyname;
  String busnum;
  LatLng mylocation;
  LatLng destinationcoordinates;
  String destination;

  @override
  State<SeatReservationScreen> createState() => _SeatReservationScreenState();
}

class _SeatReservationScreenState extends State<SeatReservationScreen> {
  @override
  void initState() {
    super.initState();
    setfields();
    getBusData();
    getDistance();
    // getAmount();
  }

  void setfields() async {
    currentlocc = await ApiCalls()
        .getBarangay(widget.mylocation.latitude, widget.mylocation.longitude);
    setState(() {});
  }

  Future<void> updateDocument() async {
    await FirebaseFirestore.instance
        .collection('passengers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'hasreservation': true,
    }).then((_) async {
      print("update Successful");
      await FirebaseFirestore.instance.collection('passengers').doc(FirebaseAuth.instance.currentUser?.uid).collection('reservations').doc(presID).set({
        "reservation_number" : presID,
        "date_and_time" : current,
        "from" : currentlocc,
        "to" : widget.destination,
        "fare" : double.parse(amount.toString()),
        "distance_traveled" : distance,
        "busnumber": widget.busnum,
        "bus_company" : widget.companyname
      }).then((value){
        print("Reservation Successful");
        QuickAlert.show(context: context, 
        type: QuickAlertType.success,
        title: "Reservation Successful",
        showConfirmBtn: true,
        onConfirmBtnTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const HomeScreen()));
        }
        );
      }).catchError((error){
        print(error.toString());
      });
    }).catchError((error) {
      print('Failed to update document: $error');
    });
  }

  Future<void> updateBusData(int avail, int occu, int res) async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('buses')
        .doc(widget.busnum)
        .update({
      'available_seats': avail - 1,
      'occupied_seats': occu + 1,
      'reserved_seats': res + 1
    }).then((value) {
      print('Bus Data Updated');
    }).catchError((error) {
      print('Error updating the bus data');
    });
  }

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
        setState(() {
          seatsavail = data['available_seats'];
          occ = data['occupied_seats'];
          reserved = data['reserved_seats'];
        });
      } else {
        print('Unable to find data');
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
      setState(() {
        presID = "000001";
      });
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('buses')
          .doc(widget.busnum)
          .collection('reservations')
          .doc('000001')
          .set({
        'passengerId': FirebaseAuth.instance.currentUser!.uid,
        'amount': double.parse(amount.toString()),
        'distance': distance,
        'from': currentlocc,
        'to': widget.destination,
        'date_time': current,
        'seats_reserved': 1,
        'accomplished': false
      }).then((value) {
        updateBusData(seatsavail, occ, reserved);
        updateDocument();
        // Navigator.of(context).pop();
      }).catchError((error) {
        print('Error');
      });
    } else {
      int entries = snapshots.docs.length + 1;
      String reservationNumber = entries.toString().padLeft(6, '0');
      setState(() {
        presID = reservationNumber;
      });
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('buses')
          .doc(widget.busnum)
          .collection('reservations')
          .doc(reservationNumber)
          .set({
        'passengerId': FirebaseAuth.instance.currentUser!.uid,
        'amount': double.parse(amount.toString()),
        'distance': distance,
        'from': currentlocc,
        'to': widget.destination,
        'date_time': current,
        'seats_reserved': 1,
        'accomplished': false
      }).then((value) {
        updateBusData(seatsavail, occ, reserved);
        updateDocument();
        // Navigator.of(context).pop();
      }).catchError((error) {
        print(error);
      });
    }
  }

  String? selectedCity;
  LatLng coordinates = const LatLng(120.09093123, 129.10319823798);
  var currentloccon = TextEditingController();
  String currentlocc = "";
  var seatscon = TextEditingController();
  DateTime current = DateTime.now();
  String? distance;
  String? amount;
  int occ = 0;
  int reserved = 0;
  double? original;
  String? presID;

  double containerheightcalculator(String content) {
    // Define base height and scaling factors
    double baseHeight = 27; // Minimum height
    double charHeightFactor =
        1.5; // Height increment per character (adjust as needed)
    int maxCharsInLine =
        20; // Approximate number of characters that fit in one line

    // Calculate how many lines the content would take
    int lines = (content.length / maxCharsInLine).ceil();

    // Calculate the height based on number of lines
    double height = baseHeight + (lines * charHeightFactor * 7);

    // Ensure a minimum height is set
    return height;
  }

  void getDistance() async {
    String? response = await ApiCalls()
        .getDistance(widget.mylocation, widget.destinationcoordinates);

    setState(() {
      distance = response;
    });

    getAmount(response.toString());
  }

  int seatsavail = 0;

  void getAmount(String distance) {
    List<String> km = distance.toString().split(' ');
    double val = double.parse(km[0]);
    amount = (val * 2.25).toStringAsFixed(2);
    original = double.parse(amount.toString());
    setState(() {});
  }

  void amountCalculator(String type){

    // double original = double.parse(amount.toString());
    if(type == "Regular"){
      setState(() {
        amount = original.toString();
      });
    }else{
      setState(() {
        amount = (double.parse(amount.toString()) * 0.80).toString();
      });
    }
  }

  String selectedCategory = 'Regular'; // Default value

  // List of categories
  final List<String> categories = [
    'Regular',
    'Student',
    'Senior Citizen',
    'PWD'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextContent(name: 'Reservation', fcolor: Colors.black),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Gap(1),
                TextContent(
                  name: widget.companyname.toUpperCase(),
                  fontsize: 18,
                  fontweight: FontWeight.w700,
                  fcolor: Colors.black,
                ),
                const Divider(
                  color: Colors.black,
                ),
                const Image(
                  image: AssetImage('assets/icons/dagupan_bus.png'),
                  height: 100,
                ),
                const Gap(10),
                TextContent(
                  name: 'Bus #: ${widget.busnum}',
                  fcolor: Colors.black,
                  fontsize: 20,
                  fontweight: FontWeight.bold,
                ),
                TextContent(
                  name: 'Date: $current',
                  fcolor: Colors.black,
                ),
                Row(
                  children: [
                    // Gap(MediaQuery.sizeOf(context).width/4 - 15),
                    const Spacer(),
                    TextContent(
                      name: 'Available Seats: $seatsavail',
                      fcolor: Colors.black,
                      fontsize: 20,
                    ),
                    const Icon(Icons.chair),
                    const Spacer()
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    TextContent(
                      name: 'From:',
                      fcolor: Colors.black,
                      fontsize: 15,
                      fontweight: FontWeight.w600,
                    ),
                    const Gap(10),
                    Expanded(
                      child: ContentContainer(
                        content: Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextContent(
                            name: currentlocc.toUpperCase(),
                            fontweight: FontWeight.bold,
                            fontsize: 14,
                          ),
                        ),
                        height: containerheightcalculator(currentlocc),
                      ),
                    )
                  ],
                ),
                const Gap(3),
                Row(
                  children: [
                    TextContent(
                      name: 'To:',
                      fcolor: Colors.black,
                      fontsize: 15,
                      fontweight: FontWeight.w600,
                    ),
                    const Gap(10),
                    Expanded(
                      child: ContentContainer(
                        content: Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextContent(
                            name: widget.destination.toUpperCase(),
                            fontweight: FontWeight.bold,
                            fontsize: 14,
                          ),
                        ),
                        height: containerheightcalculator(widget.destination),
                      ),
                    )
                  ],
                ),
                const Gap(10),
                Row(
                  children: [
                    const Spacer(),
                    DataContainer(
                      leadingwidget: const Icon(
                        Icons.chair,
                        size: 30,
                      ),
                      datawidget: TextContent(
                        name: "1",
                        fontweight: FontWeight.bold,
                        fontsize: 20,
                      ),
                    ),
                    const Spacer(),
                    DataContainer(
                      leadingwidget: TextContent(
                        name: "DISTANCE ",
                        fontweight: FontWeight.bold,
                      ),
                      datawidget: distance != null
                          ? TextContent(
                              name: distance.toString(),
                              fontsize: 20,
                              fontweight: FontWeight.bold,
                            )
                          : const CircularProgressIndicator(),
                    ),
                    const Spacer()
                  ],
                ),
                const Gap(10),
                Row(
                  children: [
                    // const Spacer(),
                    TextContent(
                      name: "Fare: ",
                      fontsize: 15,
                    ),
                    DataContainer(
                      leadingwidget: const Icon(
                        Icons.php,
                        size: 30,
                      ),
                      datawidget: amount != null ? TextContent(
                        name: amount.toString(),
                        fontweight: FontWeight.bold,
                        fontsize: 20,
                      ) : const CircularProgressIndicator(),
                    ),
                    const Spacer(),
                     
                    // DataContainer(leadingwidget: TextContent(name: "DISTANCE ", fontweight: FontWeight.bold,), datawidget: distance != null ? TextContent(name: distance.toString(), fontsize: 20, fontweight: FontWeight.bold,) : const CircularProgressIndicator(),),
                    const Spacer()
                  ],
                ),
                const Gap(22),
                Row(
                  children: [
                    TextContent(name: "Choose Type : ", fontsize: 17,),
                    const Gap(10),
                    DropdownButton<String>(
                            value: selectedCategory,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 16,
                            elevation: 20,
                            style: const TextStyle(color: Colors.black, fontSize: 19),
                            underline: Container(
                              height: 2,
                              color: Colors.redAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                              amountCalculator(selectedCategory);
                            },
                            items: categories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        ),
                  ],
                ),
                const Gap(70),
                EButtons(onPressed: reserve, name: "Reserve", bcolor: Colors.redAccent, tcolor: Colors.white, elevation: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
