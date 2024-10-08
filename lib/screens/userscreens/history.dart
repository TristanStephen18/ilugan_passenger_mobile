import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: TextContent(
          name: 'Bus Travel History',
          fontsize: 20,
          fcolor: Colors.white,
          fontweight: FontWeight.w500,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ReservationList(), // Add the list view here
    );
  }
}

class ReservationList extends StatelessWidget {
  final String passengerId = FirebaseAuth.instance.currentUser!.uid;

  // Function to format the Firestore Timestamp
  String formatDate(Timestamp timestamp) {
    var date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – kk:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('passengers')
          .doc(passengerId)
          .collection('reservations')
          .orderBy('date_and_time', descending: true) // Sort by date
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No reservations found.'));
        }

        // Get the reservation data
        final reservationDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reservationDocs.length,
          itemBuilder: (context, index) {
            var reservation = reservationDocs[index];

            // Extract the timestamp and format it
            Timestamp timestamp = reservation['date_and_time'];
            String formattedDate = formatDate(timestamp);

            return Card(
              margin: EdgeInsets.all(10),
              elevation: 4,
              child: ListTile(
                title: Row(
                  children: [
                    TextContent(name: '${reservation['bus_company']}', fontsize: 17, fontweight: FontWeight.bold,),
                    const Spacer(),
                    TextContent(name: 'Php ${reservation['fare'].toStringAsFixed(2)}', fontsize: 17, fontweight: FontWeight.bold,),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextContent(name: 'Date: $formattedDate'),
                    TextContent(name: 'Destination: ${reservation['to'].toString().toUpperCase()}', fontsize: 15,),
                  ],
                ),
                isThreeLine: true,
                // trailing: Text('Fare: Php ${reservation['fare']}'),
              ),
            );
          },
        );
      },
    );
  }
}
