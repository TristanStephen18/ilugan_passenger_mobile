import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilugan_passenger_mobile_app/screens/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/signupscreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 141, 75),
      body: Center(
        child: Column(
          children: [
            const Gap(50),
            Image(
              image: const AssetImage("assets/images/logo/logo.png"),
              width: MediaQuery.sizeOf(context).width/2,
              height: 250,
            ),
            Text(
              "ILugan",
              style: GoogleFonts.inter(
                fontSize: 40,
                color: Colors.white
              ),
              ),
              const Gap(200),
              Buttons(
                onPressed: (){
                  print("Log In");
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_)=>LoginScreen()));
                },
                name: "Log In",
              ),
              const Gap(30),
              Buttons(
                onPressed: (){
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_)=>SignUpScreen()));
              }, name: "Sign Up"),
              const Gap(160)
          ],
        ),
      ),
    );
  }
}
