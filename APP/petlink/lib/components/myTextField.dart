import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintString;
  final TextEditingController? controller; // Nuevo parámetro opcional
  final int? maxLength;
  
  const MyTextField({super.key, required this.hintString, this.controller, this.maxLength});

  @override
  Widget build(BuildContext context) {

    final fondo = Color.fromARGB(255, 230, 230, 230);
    return TextField(
      controller: controller, // Asignar controlador si existe
      maxLength: maxLength,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: fondo,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            width: 3,
            color: fondo,
          ), // Borde cuando está enfocado
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: fondo,
          ), // Borde cuando NO está enfocado
        ),
        hintText: hintString,
        hintStyle: TextStyle(color: Colors.grey)
      ),
    );
  }
}
