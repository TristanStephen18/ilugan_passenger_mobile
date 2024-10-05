import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ilugan_passenger_mobile_app/screens/authentication/emailverification.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _validatePasswords() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_validatePasswords()) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Passwords do not match',
          text: 'Please re-enter your password',
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EmailVeficationScreen(
              username: _usernameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              // phonenum: '+63${_phoneController.text}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE7E7),
      appBar: AppBar(
        title: const Text(
          "Back",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.red,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Image(
              image: AssetImage("assets/images/logo/logo.png"),
              height: 32,
              width: 32,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create your ILugan Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(3),
                const Text("Please fill in the following"),
                const Gap(40),
                const Text("Create a username"),
                const Gap(5),
                Tfields(
                  field_controller: _usernameController,
                  suffixicon: Icons.person,
                ),
                const Gap(10),
                const Text("Email"),
                const Gap(5),
                Tfields(
                  field_controller: _emailController,
                  suffixicon: Icons.mail_outline,
                ),
                const Gap(10),
                const Text("Create Password"),
                const Gap(5),
                Password_Tfields(
                  field_controller: _passwordController,
                  showpassIcon: Icons.visibility,
                  hidepassIcon: Icons.visibility_off,
                  showpass: true,
                ),
                const Gap(10),
                const Text("Confirm Password"),
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
                    name: "Create Account",
                    bcolor: Colors.red,
                    tcolor: Colors.white,
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
