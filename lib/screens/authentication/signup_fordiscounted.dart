import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class DiscountedSignUPScreen extends StatefulWidget {
  DiscountedSignUPScreen({super.key, this.idimage, required this.acctype});

  String acctype;
  File? idimage;

  @override
  _DiscountedSignUPScreenState createState() => _DiscountedSignUPScreenState();
}

class _DiscountedSignUPScreenState extends State<DiscountedSignUPScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController();

  bool _validatePasswords() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_validatePasswords()) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Passwords do not match',
          text: 'Please re-enter your password',
        );
      } else {
        uploadIdToStorage();
      }
    }
  }

  void uploadIdToStorage() async {
  if (widget.idimage != null) {
    // Assuming widget.idimage is a File
    File file = widget.idimage!;  // Ensure that widget.idimage is a File
    String path = 'idpictures/${file.path.split('/').last}';  // Use the file name from its path

    // Reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(path);

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(file);

    // Optional: Listen to upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    });

    // Wait for the upload to complete
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {
      print('File uploaded!');
    });

    // Get the download URL for the uploaded file
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    print('Download URL: $downloadURL');

    await FirebaseFirestore.instance.collection('requests').doc(_emailController.text).set({
        'email': _emailController.text,
        'password': _passwordController.text,
        'type': widget.acctype,
        'imagelocation': downloadURL,
        'status' : 'pending'  // Save the download URL in Firestore
      });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Request sent!',
        text: 'Your account request has been submitted.',
      );
  } else {
    print('No file selected');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.redAccent,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        title: TextContent(name: 'Create Account', fontsize: 
        20, fcolor: Colors.white, fontweight: FontWeight.w500,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.redAccent,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Image(
              image: AssetImage("assets/images/logo/logo.png"),
              height: 50,
              width: 50 ,
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundimages/signupbg.avif'),
            opacity: 0.8,
            alignment: Alignment.bottomCenter
            )
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextContent(name: "Create your ILugan Account and start your adventure!", fontsize: 17,fontweight: FontWeight.bold,),
                  const Gap(3),
                  TextContent(name: "Please fill in the following"),
                  const Gap(40),
                  TextContent(name: "Create a username"),
                  const Gap(5),
                  Tfields(
                    field_controller: _usernameController,
                    suffixicon: Icons.person,
                  ),
                  const Gap(10),
                  TextContent(name: "Email"),
                  const Gap(5),
                  Tfields(
                    field_controller: _emailController,
                    suffixicon: Icons.mail_outline,
                  ),
                  const Gap(10),
                  TextContent(name: "Create Password"),
                  const Gap(5),
                  Password_Tfields(
                    field_controller: _passwordController,
                    showpassIcon: Icons.visibility,
                    hidepassIcon: Icons.visibility_off,
                    showpass: true,
                  ),
                  const Gap(10),
                  TextContent(name: "Confirm Password"),
                  const Gap(5),
                  Password_Tfields(
                    field_controller: _confirmPasswordController,
                    showpassIcon: Icons.visibility,
                    hidepassIcon: Icons.visibility_off,
                    showpass: true,
                  ),
                  const Gap(60),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: EButtons(
                      onPressed: _submit,
                      name: "Send Request",
                      bcolor: Colors.red,
                      tcolor: Colors.white,
                      elevation: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
