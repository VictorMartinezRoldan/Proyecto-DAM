import 'package:flutter/material.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';

class StartingAnimation extends StatefulWidget {
  const StartingAnimation({super.key});

  @override
  State<StartingAnimation> createState() => _StartingAnimationState();
}

class _StartingAnimationState extends State<StartingAnimation> with SingleTickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Tiene conexión a internet?
  late bool isConnected;

  // Condicionadores de visualización
  bool moveLogoLeft = false;
  bool showLogo = true;
  bool showText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.7)
        .chain(CurveTween(curve: Curves.easeInBack))
        .animate(_controller);

    // Una vez a terminado la animación del "pop"...
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          moveLogoLeft = true; // Mueve el logo a la izquierda
        });
      }
    });

    _controller.forward().then((_) => _controller.reverse()); // Efecto pop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = "assets/logos/petlink_${(Provider.of<ThemeProvider>(context).isLightMode) ? "black" : "white"}.png";
    return Scaffold(
      body: Stack(
        children: [
          // LOGO animado que se mueve
          AnimatedOpacity(
            duration: Duration(milliseconds: 800),
            opacity: (showLogo) ? 1 : 0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              alignment: moveLogoLeft ? Alignment.centerLeft : Alignment.center,
              onEnd: () async {
                // Al terminar la animación hacia la izquierda...
                if (moveLogoLeft) {
                  setState(() {
                    showText = true; // Enseña el texto "PETLINK"
                  });

                  // TEST DE CONEXION
                  isConnected = await Seguridad.comprobarConexion();

                  await Future.delayed(Duration(milliseconds: 1000)); // Espera un poco

                  // Hace desaparecer tanto el logo como el texto
                  setState(() {
                    showLogo = false;
                    showText = false;
                  });

                  await Future.delayed(Duration(milliseconds: 900)); // Espera a que terminen las animaciones

                  // Redirección dependiendo de su estado de conexión
                  if (isConnected){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => PagesManager()),
                      (Route<dynamic> route) => false
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => NetworkErrorPage()),
                      (Route<dynamic> route) => false
                    );
                  }

                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Image.asset(logo, height: 120, width: 120),
                  ),
                ),
              ),
            ),
          ),

          // TEXTO "PETLINK" siempre está presente pero opacidad cambia
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 170.0), // al lado del logo,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 800),
              opacity: showText ? 1 : 0,
              child: Text(
                "PETLINK",
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}