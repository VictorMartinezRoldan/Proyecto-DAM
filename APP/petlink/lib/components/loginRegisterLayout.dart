import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class LoginRegisterLayout extends StatelessWidget {
  final Widget child;
  final IconData iconoSuperior;
  // Para que el layout ocupe un % de la pantalla concreto
  final double contentHeightFactor;
  final String? imagenFondo;
  final PreferredSizeWidget? appBar;

  const LoginRegisterLayout({
    Key? key,
    required this.child,
    required this.iconoSuperior,
    this.contentHeightFactor = 0.70,
    this.imagenFondo = 'assets/imagenFondoPerro.png',
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final custom = Theme.of(context).extension<CustomColors>()!;
    
    return GestureDetector(
      onTap: () {
        // Ocultar el teclado cuando se toca fuera del TextField
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // Solo si hay appbar
        extendBodyBehindAppBar: appBar != null,
        appBar: appBar,
        body: Stack(
          children: [
            // Imagen de fondo
            if (imagenFondo != null)
              Positioned(
                top: -80,
                left: -150,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 1.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagenFondo!),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            // Contenedor donde irá el contenido propio de cada pantalla
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * contentHeightFactor,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: custom.contenedor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(38),
                        topRight: Radius.circular(38),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 60, // Espacio para el icono flotante
                        bottom: 20,
                      ),
                      // El widget child sera la pantalla que utilizara este widget
                      child: child,
                    ),
                  ),
                  // Icono circular superior
                  Positioned(
                    top: -40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: custom.contenedor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: custom.bordeContenedor.withValues(alpha: 0.05),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            iconoSuperior,
                            size: 45,
                            color: custom.colorEspecial,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
