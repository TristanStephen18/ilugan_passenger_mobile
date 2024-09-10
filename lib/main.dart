import 'package:flutter/material.dart';
import 'package:ilugan_passenger_mobile_app/screens/splashscreen.dart';

void main(){
  runApp(const Ilugan());
}

class Ilugan extends StatelessWidget {
  const Ilugan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
}