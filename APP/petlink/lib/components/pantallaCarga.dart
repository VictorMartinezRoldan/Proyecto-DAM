import 'package:flutter/material.dart';

// CLASES
import 'package:petlink/themes/customColors.dart';

// Widget que muestra una pantalla de carga con animación de fade y un icono centrado
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({
    super.key,
    required this.tema, // Esquema de colores del tema
    required this.custom, // Colores personalizados
    required this.onFinalizadoFadeOut, // Callback cuando termina la animación de salida
  });

  final ColorScheme tema;
  final CustomColors custom;
  final VoidCallback onFinalizadoFadeOut;

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controla la animación de opacidad
  late Animation<double> _fade; // Define la curva de animación

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0, // Empieza visible (opacidad total)
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut); // Animación suavizada
  }

  Future<void> desaparecer() async {
    await _controller.reverse(); // Ejecuta el fade out
    widget.onFinalizadoFadeOut(); // Informa al widget padre que terminó
  }

  // INTERFAZ DE LA PANTALLA DE CARGA
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade, // Aplica animación de opacidad
      child: Container(
        color: widget.tema.surface, // Fondo basado en el tema
        child: Center(
          child: Icon(
            Icons.pets_rounded,
            color: widget.custom.colorEspecial, // Icono con color personalizado
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}