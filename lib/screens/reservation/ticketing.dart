import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/screens/reservation/widgets.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 182, 179, 179),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: TextContent(name: 'Ticketing', fontsize: 
        20, fcolor: Colors.white, fontweight: FontWeight.w500,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          height: MediaQuery.sizeOf(context).height - 35,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Gap(10),
                TextContent(
                  name: 'Reservation #: 000003',
                  fontsize: 19,
                  fontweight: FontWeight.bold,
                ),
                TextContent(
                  name: 'Company Name',
                  fontweight: FontWeight.w600,
                ),
                const Divider(),
                const Gap(20),
                TicketDataDisplayer(
                  leading: const Icon(Icons.location_history),
                  subtitle: TextContent(
                    name: 'Panagsinan State University, Urdaneta City Campus',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: 'Pick Up Location',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                // const Divider()
                TicketDataDisplayer(
                  leading: const Icon(Icons.location_searching_rounded),
                  subtitle: TextContent(
                    name: 'SM City, Baguio',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: 'Destination',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                
                TicketDataDisplayer(
                  leading: const Icon(Icons.chair),
                  subtitle: TextContent(
                    name: 'Availed Seats',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: '1 seat',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                TicketDataDisplayer(
                  leading: const Icon(Icons.php, size: 30,),
                  subtitle: TextContent(
                    name: 'Fare',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: '125.56',
                    fontsize: 18,
                    fontweight: FontWeight.bold,
                  ),
                ),
                TicketDataDisplayer(
                  leading: const Icon(Icons.discount),
                  subtitle: TextContent(
                    name: 'Discounted',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: '20%',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                TicketDataDisplayer(
                  leading: const Icon(Icons.route),
                  subtitle: TextContent(
                    name: 'Distance',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: '89.12 km',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                TicketDataDisplayer(
                  leading: const Icon(Icons.person_4),
                  subtitle: TextContent(
                    name: 'Conductor',
                    fontsize: 15,
                  ),
                  title: TextContent(
                    name: 'Tristan Rasco',
                    fontsize: 15,
                    fontweight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
               EButtons(onPressed: (){}, name: 'Pay Now', bcolor: Colors.redAccent, tcolor: Colors.white,),
               const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
