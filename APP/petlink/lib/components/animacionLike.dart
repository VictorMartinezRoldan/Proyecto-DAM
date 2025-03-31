import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

// Widget que muestra un corazón animado al hacer doble tap (estilo Instagram)
// Se puede controlar externamente mediante una GlobalKey
class AnimacionLike extends StatefulWidget {
  const AnimacionLike({super.key});

  @override
  State<AnimacionLike> createState() => AnimacionLikeState();
}

class AnimacionLikeState extends State<AnimacionLike>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controlador para la animación de escala
  late Animation<double> _scaleAnimation; // Animación que agranda y reduce el corazón
  bool _mostrarCorazon = false; // Controla si el corazón debe mostrarse

  @override
  void initState() {
    super.initState();

    // Configura el controlador de animación con duración corta
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    // Crea una animación de escala con efecto suave
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Lógica para ocultar el corazón tras la animación
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 200), () {
          _controller.reverse(); // Vuelve al tamaño original
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _mostrarCorazon = false; // Oculta el corazón después de reducir
        });
      }
    });
  }

  // Método que se llama externamente cuando se hace doble tap
  void onDoubleTap() {
    setState(() {
      _mostrarCorazon = true; // Muestra el corazón
    });
    _controller.forward(from: 0.0); // Inicia la animación
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene los colores personalizados y el esquema de colores del tema
    late var custom = Theme.of(context).extension<CustomColors>()!;
    late var tema = Theme.of(context).colorScheme;

    // Si _mostrarCorazon es true, muestra la animación de escala con el corazón
    return _mostrarCorazon
        ? ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.redAccent, size: 60),
                Icon(Icons.pets, color: Colors.white, size: 20),
              ],
            ),
          )
        : SizedBox.shrink(); // Si no se debe mostrar, devuelve un widget vacío
  }
}