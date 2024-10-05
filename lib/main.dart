import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ilugan_passenger_mobile_app/otp_trial/sendotp.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/emailverification.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/homescreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/signupscreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/profile.dart';
import 'package:ilugan_passenger_mobile_app/trial/psgc.dart';
import 'firebase_options.dart';
import 'package:ilugan_passenger_mobile_app/screens/index/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EmailOTP.config(
    appName: 'Ilugan',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // home: const ApiTry(),
      home: const SplashScreen(),
    );
  }
}