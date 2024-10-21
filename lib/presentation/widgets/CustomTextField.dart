import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.nameTextFieldController,
  }) : super(key: key);

  final TextEditingController nameTextFieldController;

  @override
  Widget build(BuildContext context) {
    return Container(margin: EdgeInsets.all(5),
        child: 
      TextField(
      controller: nameTextFieldController,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(
          color: Color.fromARGB(255, 5, 5, 5),
          fontFamily: 'Segoe UI',
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 0, color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0,
            color:Colors.white,
          ),
        ),
      ),
      ) );
  }
}
