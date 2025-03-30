import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class MyTextFieldPassword extends StatefulWidget {
  final TextEditingController? controller; // Nuevo parámetro opcional
  const MyTextFieldPassword({super.key, this.controller});

  @override
  State<MyTextFieldPassword> createState() => _MyTextFieldPasswordState();
}

class _MyTextFieldPasswordState extends State<MyTextFieldPassword> {
  bool passVisibleState = false;

  bool isPassVisible() {
    return passVisibleState;
  }

  @override
  Widget build(BuildContext context) {
    // ATRIBUTOS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    
    final fondo = Color.fromARGB(255, 230, 230, 230);
    // Interfaz
    return TextField(
      controller: widget.controller, // Asignar controlador si existe
      obscureText: !passVisibleState,
      style: TextStyle(color: tema.primary),
      decoration: InputDecoration(
        filled: true,
        fillColor: fondo,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              passVisibleState = !passVisibleState;
            });
          },
          icon: Icon(
            isPassVisible()
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        suffixIconColor: Colors.grey,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: fondo,
          ), // Borde cuando está enfocado
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            width: 3,
            color: fondo,
          ), // Borde cuando NO está enfocado
        ),
        hintText: "Introduce una contraseña",
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
