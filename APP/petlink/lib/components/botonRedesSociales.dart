import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class BotonRedesSociales extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const BotonRedesSociales({required this.icon, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: custom.contenedor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: custom.bordeContenedor.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: custom.colorEspecial.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: custom.bordeContenedor.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}
