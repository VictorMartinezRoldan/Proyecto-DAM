import 'package:flutter/material.dart';

class BlueButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Nuevo parámetro para manejar acciones
  const BlueButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return GestureDetector(
      onTap: onPressed, // Usar el callback cuando se presione el botón
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: tema.inversePrimary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}