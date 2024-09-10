import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/screens/landingscreen.dart';
// import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: const Color.fromARGB(255, 72, 141, 75),
      splash:  const Center(
        child: Image(
                    image: AssetImage(
                      "assets/images/logo/logo.png",
                    ),
        ),
      ),
    splashIconSize: 300,
    nextScreen: const LandingScreen());
  }
}