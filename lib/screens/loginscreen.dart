import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formkey = GlobalKey<FormState>();

  var emailcon = TextEditingController();
  var passcon = TextEditingController();

  void checklogin(){
    if (formkey.currentState!.validate()) {
      // Your login logic here
      print(emailcon.text);
    } else {
      // print(emailcon.text);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 141, 75),
      appBar: AppBar(
        title: TextContent(
          name: "Back",
          fontsize: 15,
          fcolor: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Image(
            image: AssetImage("assets/images/logo/logo.png"),
            height: 32,
            width: 32,
          ),
          Gap(10)
        ],
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.6,
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContent(
                        name: "Hello.",
                        fcolor: Colors.white,
                        fontsize: 33,
                        fontweight: FontWeight.bold,
                      ),
                      TextContent(
                        name: "Welcome back! Kindly enter your",
                        fcolor: Colors.white,
                      ),
                      TextContent(name: "login details. ", fcolor: Colors.white),
                      const Gap(40),
                      TextContent(name: "Email", fcolor: Colors.white),
                      const Gap(5),
                      Tfields(
                        field_controller: emailcon,
                        suffixicon: Icons.mail_outline,
                      ),
                      const Gap(20),
                      TextContent(name: "Password", fcolor: Colors.white),
                      const Gap(5),
                      Password_Tfields(
                        field_controller: passcon, 
                        showpassIcon: Icons.visibility,
                        hidepassIcon: Icons.visibility_off,
                        showpass: true,
                      ),
                      const Gap(10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot User Password?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight * 0.4,
                  width: screenWidth,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 89),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90),
                        child: EButtons(onPressed: checklogin, name: "Log In"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
