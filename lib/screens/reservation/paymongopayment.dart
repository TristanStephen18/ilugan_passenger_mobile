import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ilugan_passenger_mobile_app/api/apicalls.dart';
import 'package:ilugan_passenger_mobile_app/screens/reservation/ticketdownload.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key, 
      required this.link, 
      required this.companyId,
      required this.current,
      required this.currentlocc,
      required this.destination,
      required this.amount,
      required this.busnum,
      required this.companyname,
      required this.distance,
      required this.type,
      required this.resnum,
      required this.paymentId
      });

  DateTime current;
  String currentlocc;
  String destination;
  String amount;
  String busnum;
  String companyname;
  String companyId;
  String distance;
  String type;
  String resnum;
  String paymentId;

  final String link; // Make it a final since it's passed as a required argument.

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController controller;
  String? paymentlink;
   int occ = 0;
  int reserved = 0;
  int seatsavail = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the payment link when the widget is created.
    paymentlink = widget.link;
    getBusData();
    checkpayment();

    // Initialize the WebView controller when the payment link is available.
    if (paymentlink != null) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(paymentlink!));
    }
  }

  String? presID;

  Future<void> updateDocument() async {
    await FirebaseFirestore.instance
        .collection('passengers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'hasreservation': true,
    }).then((_) async {
      print("update Successful");
      await FirebaseFirestore.instance
          .collection('passengers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('reservations')
          .doc(presID)
          .set({
        "reservation_number": widget.resnum,
        "date_and_time": widget.current,
        "from": widget.currentlocc,
        "to": widget.destination,
        "fare": double.parse(widget.amount.toString()),
        "distance_traveled": widget.distance,
        "busnumber": widget.busnum,
        "bus_company": widget.companyname
      }).then((value) {
        print("Reservation Successful");
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Ticket(
                  amount: widget.amount,
                  busnum: widget.busnum,
                  companyname: widget.companyname,
                  current: widget.current,
                  currentlocc: widget.currentlocc,
                  destination: widget.destination,
                  distance: widget.distance,
                  type: widget.type,
                  resnum: widget.resnum,
                )));
      }).catchError((error) {
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
          // conductorname = data['conductor'];
        });
      } else {
        print('Unable to find data');
      }
    });
  }

    Timer? _checkstatustimer;

  void checkpayment() {
    print("clicked");
    _checkstatustimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Call the async function separately
      // print(link.split(" ")[1]);
      String? status = await ApiCalls().checkpaymentstatus(widget.paymentId);
      print(status);
      if (status == "paid") {
        print("Payment successful, cancelling timer.");
        _checkstatustimer?.cancel(); // Use the passed timer to cancel
        reserve();
      }
    });
  }

  void reserve() async {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('buses')
        .doc(widget.busnum)
        .collection('reservations')
        .doc(widget.resnum)
        .set({
      'passengerId': FirebaseAuth.instance.currentUser!.uid,
      'amount': double.parse(widget.amount.toString()),
      'distance': widget.distance,
      'from': widget.currentlocc,
      'to': widget.destination,
      'date_time': widget.current,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextContent(
          name: 'Payment',
          fontsize: 20,
          fcolor: Colors.white,
          fontweight: FontWeight.w500,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: paymentlink != null
          ? WebViewWidget(controller: controller)
          : const Center(child: CircularProgressIndicator()), 
    );
  }
}
