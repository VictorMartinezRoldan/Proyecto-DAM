import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class MyTextField extends StatelessWidget {
  final String hintString;
  final TextEditingController? controller; // Nuevo parámetro opcional
  const MyTextField({super.key, required this.hintString, this.controller});

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    
    final fondo = Color.fromARGB(255, 230, 230, 230);
    return TextField(
      controller: controller, // Asignar controlador si existe
      style: TextStyle(color: tema.primary),
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
