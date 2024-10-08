import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/addphonenumber.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/homescreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
 const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserid();
  }

  bool toggleedit = false;
  String userid = "";

  void getuserid(){
    User? userpf =  FirebaseAuth.instance.currentUser;
    setState(() {
      userid = userpf!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: TextContent(
            name: 'Profile',
            fcolor: Colors.white,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // actions: [
          //   IconButton(onPressed: (){
          //     setState(() {
          //       toggleedit = !toggleedit;
          //     });
          //   }, icon: const Icon(Icons.edit))
          // ],
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('passengers').doc(userid).get(), 
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User not found'));
        } 

         var userData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/icons/pfp.png'),
                        radius: 60,
                      ),
                    ),
                    const Gap(70),
                    ProfileTfields( 
                      label: 'Username',
                      data:  userData['username'].toString(),
                      prefix: const Icon(Icons.person, color: Colors.black,),
                      // suffixicon: Icons.edit,
                      isreadable: toggleedit,
                    ),
                    const Gap(20),
                     ProfileTfields( 
                      label: 'Email',
                      prefix: const Icon(Icons.mail, color: Colors.black,),
                      data:  userData['email'].toString(),
                    ),
                    const Gap(20),
                    TextContent(name: 'Phone',fontsize: 20, fontweight: FontWeight.w700,),
                    const Gap(10),
                    ListTile(
                      title: TextContent(name: 'Add a phone number', fcolor: Colors.blueAccent,),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=>AddPhoneNumberScreen()));
                      },
                      leading: const Icon(Icons.add),
                    ),
                    //  ProfileTfields( 
                    //   label: 'Username',
                    // ),
                    // const Gap(100),
                    // Visibility(
                    //   visible: toggleedit,
                    //   child: Center(child: EButtons(onPressed: (){}, name: 'Save Changes')))
                  ],
                ),
              ),
            );
          }
        ));
  }
}
