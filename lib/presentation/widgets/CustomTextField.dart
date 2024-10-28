import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      required this.nameTextFieldController,
      required this.isExpanded,
      required this.isEnabled})
      : super(key: key);

  final TextEditingController nameTextFieldController;
  final bool isExpanded;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
        child: TextField(
          enabled: isEnabled,
          maxLength: isExpanded ? null : 40,
          maxLines: isExpanded ? null : 1,
          controller: nameTextFieldController,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 5, 5, 5),
              fontFamily: 'Segoe UI',
            ),
            disabledBorder:  OutlineInputBorder(
              borderSide: BorderSide(
                width: 0,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0, color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
