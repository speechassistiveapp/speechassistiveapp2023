import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({Key? key, required this.label, required this.value, this.suffix, required void Function(dynamic value) onChanged}) : super(key: key);
  final String label;
  final String value;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: Color.fromARGB(255, 109, 168, 226),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      TextField(
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          suffix: suffix,
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 109, 168, 226),
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 109, 168, 226),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 109, 168, 226),
            ),
          ),
        ),
      ),
    ]);
  }
}
