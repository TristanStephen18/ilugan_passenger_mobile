import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/chooseaccounttype.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/signupscreen.dart';
import 'package:ilugan_passenger_mobile_app/screens/userscreens/homescreen.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formkey = GlobalKey<FormState>();

  var emailcon = TextEditingController();
  var passcon = TextEditingController();

  void checklogin()async{
    if(formkey.currentState!.validate()){
    QuickAlert.show(context: context, type: QuickAlertType.loading, text: "Processing", title: "signing you in");
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailcon.text, 
    password: passcon.text).then((UserCredential cred) async{
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const HomeScreen()));
    }).catchError((error){
      Navigator.of(context).pop();
      QuickAlert.show(context: context, type: QuickAlertType.error, text: error.toString(), title: "OOOOpppss");
    });
  }else{
    return;
  }
  }

  @override
  Widget build(BuildContext context) {

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100,
        title:TextContent(name: 'Log in', fontsize: 
        30, fcolor: Colors.white, fontweight: FontWeight.w500,),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.yellow,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Image(
            image: AssetImage("assets/images/logo/logo.png"),
            height: 50,
            width: 50,
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
                      // const Spacer(),
                      TextContent(
                        name: "Welcome back! Kindly enter your",
                        fcolor: Colors.white,
                        fontsize: 16,
                      ),
                      TextContent(name: "login details. ", fcolor: Colors.white),
                      const Gap(40),
                      TextContent(name: "Email", fcolor: Colors.white),
                      const Gap(5),
                      LoginTfields(
                        field_controller: emailcon,
                        suffixicon: Icons.mail_outline,
                      ),
                      const Gap(20),
                      TextContent(name: "Password", fcolor: Colors.white),
                      const Gap(5),
                      LoginPassTfields(
                        field_controller: passcon, 
                        showpassIcon: Icons.visibility,
                        hidepassIcon: Icons.visibility_off,
                        showpass: true,
                      ),
                      const Gap(10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot User Password?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_)=>PassengerTypeScreen()));
                              },
                              child: TextContent(name: 'Dont have an account?', fcolor: const Color.fromARGB(255, 117, 190, 250),)
                            ),
                          ],
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                ),
                Container(
                  height: screenHeight * 0.35,
                  width: screenWidth,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 89),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90),
                        child: EButtons(onPressed: checklogin, name: "Log In", tcolor: Colors.white, bcolor: Colors.redAccent, elevation: 15,),
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
