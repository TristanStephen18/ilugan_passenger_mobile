// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/screens/loginscreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:quickalert/quickalert.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final formkey = GlobalKey<FormState>();

  var emailcon = TextEditingController();
  var passcon = TextEditingController();
  var confirmpasscon = TextEditingController();
  var usernamecon = TextEditingController();

  void submit() async {
    if(formkey.currentState!.validate()){
    try{
      QuickAlert.show(context: context, type: QuickAlertType.loading, text: "Creating account");
      UserCredential usercred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcon.text, password: passcon.text);

      String id = usercred.user!.uid;

      await FirebaseFirestore.instance.collection('passengers').doc(id).set(
        {
          'username': usernamecon.text,
          'email': emailcon.text,
          'password': passcon.text
        }
      );

      // User? user = usercred.user;

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (_)=>LoginScreen()));
    }on FirebaseAuthException catch(error){
      Navigator.of(context).pop();
      QuickAlert.show(context: context, type: QuickAlertType.error, text: "error", title: error.toString());
    }
    }else{
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
                  height: screenHeight * 0.72,
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextContent(
                        name: "Create your ILugan Account",
                        fcolor: Colors.white,
                        fontsize: 22,
                        fontweight: FontWeight.bold,
                      ),
                      const Gap(3),
                      TextContent(
                        name: "Please fill in the following",
                        fcolor: Colors.white,
                      ),
                      const Gap(40),
                      TextContent(name: "Create a username", fcolor: Colors.white),
                      const Gap(5),
                      Tfields(
                        field_controller: usernamecon,
                        suffixicon: Icons.person,
                      ),
                      const Gap(20),
                      TextContent(name: "Email", fcolor: Colors.white),
                      const Gap(5),
                      Tfields(
                        field_controller: emailcon,
                        suffixicon: Icons.mail_outline,
                      ),
                      const Gap(20),
                      TextContent(name: " Create Password", fcolor: Colors.white),
                      const Gap(5),
                      Password_Tfields(
                        field_controller: passcon, 
                        showpassIcon: Icons.visibility,
                        hidepassIcon: Icons.visibility_off,
                        showpass: true,
                      ),
                      const Gap(20),
                      TextContent(name: " Confirm Password", fcolor: Colors.white),
                      const Gap(5),
                      Password_Tfields(
                        field_controller: confirmpasscon, 
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
                  height: screenHeight * 0.18,
                  width: screenWidth,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 50),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: EButtons(onPressed: submit, name: "Sign Up"),
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
