import 'package:flutter/material.dart';

class MensajeSnackbar {
  static void mostrarError(BuildContext context, String mensaje) {
    _mostrarSnackbar(
      context,
      mensaje,
      Colors.red[400]!,
      Icons.error_outline,
    );
  }

  static void mostrarExito(BuildContext context, String mensaje) {
    _mostrarSnackbar(
      context,
      mensaje,
      Colors.green[400]!,
      Icons.check_circle_outline,
    );
  }

  static void _mostrarSnackbar(
    BuildContext context,
    String mensaje,
    Color backgroundColor,
    IconData icon,
  ) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
