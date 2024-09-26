import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';

class Fields extends StatelessWidget {
  Fields({super.key, required this.fcon, required this.label, this.leading, this.type});
  var fcon = TextEditingController();
  String label;
  IconData? leading;
  TextInputType? type;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: fcon,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            style: BorderStyle.solid
          )
        ),
        label: TextContent(name: label, fcolor: Colors.white,),
        prefixIcon: Icon(leading, color: Colors.white,),
      ),
      keyboardType: type,
      style: GoogleFonts.inter(
        color: Colors.white,
      ),
    );
  }
}

// class Fielddecor extends StatelessWidget {
//   const Fielddecor({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const InputDecoration(
      
//     );
//   }
// }