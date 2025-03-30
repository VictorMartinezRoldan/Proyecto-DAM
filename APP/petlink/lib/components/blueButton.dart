import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class BlueButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Nuevo parámetro para manejar acciones
  const BlueButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    
    return GestureDetector(
      onTap: onPressed, // Usar el callback cuando se presione el botón
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: custom.colorEspecial,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: tema.surface),
        ),
      ),
    );
  }
}