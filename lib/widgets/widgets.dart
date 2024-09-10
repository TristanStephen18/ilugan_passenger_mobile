// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatelessWidget {
  Buttons({
    super.key,
    required this.onPressed,
    required this.name
  });

  final VoidCallback onPressed;
  String name = "";

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.sizeOf(context).width - 100, 60),
        backgroundColor: Colors.white,  
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        shadowColor: Colors.black,
        elevation: 9
      ),
      child: TextContent(
        name: name,
        fontsize: 20,
        fontweight: FontWeight.bold,
        fcolor: const Color.fromARGB(255, 65, 26, 23)
        ),
      
      );
  }
}

class EButtons extends StatelessWidget {
  EButtons({
    super.key,
    required this.onPressed,
    required this.name
  });

  final VoidCallback onPressed;
  String name = "";

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.sizeOf(context).width - 150, 60),
        backgroundColor: Colors.green,  
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        shadowColor: Colors.black,
        elevation: 9
      ),
      child: TextContent(
        name: name,
        fontsize: 20,
        fontweight: FontWeight.bold,
        fcolor: const Color.fromARGB(255, 65, 26, 23)
        ),
      
      );
  }
}

class TextContent extends StatelessWidget {
  TextContent({
    super.key,
    required this.name,
    this.fontsize,
    this.fontweight,
    this.fcolor
  });

  final String name;
  double? fontsize = 0;
  FontWeight? fontweight;
  Color? fcolor;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: GoogleFonts.inter(
        fontSize: fontsize,
        fontWeight: fontweight,
        color: fcolor,
      ),
      );
  }
}

class Tfields extends StatelessWidget {
  Tfields({
    super.key,
    required this.field_controller,
    this.suffixicon,
    this.label
    });

    var field_controller = TextEditingController();
    IconData? suffixicon;
    String? label= "";

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: field_controller,
      validator: (value) {
          if(value == null || value.isEmpty){
            return 'Please fill up this field';
            }
            return null;
          },
      style: const TextStyle(
        color: Colors.white
      ),
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        suffixIcon: Icon(suffixicon, color: Colors.white,),
         enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white, 
            width: 1.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, 
            width: 1.0,
          ),
        ),
      ),
    );
  }
}

class Password_Tfields extends StatefulWidget {
  Password_Tfields({
    super.key,
    required this.field_controller,
    required this.showpassIcon,    
    required this.hidepassIcon, 
    required this.showpass,
    // required this.togglepass
    });

    var field_controller = TextEditingController();
    IconData? showpassIcon;
    IconData?  hidepassIcon;
    bool showpass;

  @override
  State<Password_Tfields> createState() => _Password_TfieldsState();
}

class _Password_TfieldsState extends State<Password_Tfields> {
    // final VoidCallback togglepass;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.field_controller,
    validator: (value) {
        if(value == null || value.isEmpty){
          return 'Please fill up this field';
          }
          return null;
      },
      obscureText: widget.showpass,
      style: const TextStyle(
        color: Colors.white
      ),
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        suffixIcon: IconButton(onPressed: (){
          setState(() {
            widget.showpass = !widget.showpass;
          });
        }, icon:Icon( widget.showpass ? widget.hidepassIcon : widget.showpassIcon, color: Colors.white,)),
         enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white, 
            width: 1.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, 
            width: 1.0,
          ),
        ),
      ),
    );
  }
}