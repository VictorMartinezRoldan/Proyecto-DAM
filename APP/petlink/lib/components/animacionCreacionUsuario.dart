import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:petlink/themes/customColors.dart';

class AnimacionCreacionUsuario extends StatefulWidget {
  final String? imagenPerfilUrl;
  final String nombreUsuario;
  final VoidCallback onAnimacionCompleta;

  const AnimacionCreacionUsuario({
    super.key,
    required this.imagenPerfilUrl,
    required this.nombreUsuario,
    required this.onAnimacionCompleta,
  });

  @override
  State<AnimacionCreacionUsuario> createState() => _AnimacionCreacionUsuarioState();
}

class _AnimacionCreacionUsuarioState extends State<AnimacionCreacionUsuario>
    with TickerProviderStateMixin {
  // Controladores de animacion
  late AnimationController _fadeController;
  late AnimationController _controladorEscala;
  late AnimationController _controladorDesvanecimiento;
  late AnimationController _controladorOpacidadFuegos;

  AnimationController? _controladorLottie1;
  AnimationController? _controladorLottie2;

  // Animaciones
  late Animation<double> _animacionDesvanecimiento;
  late Animation<double> _animacionEscala;
  late Animation<Offset> _animacionDesplazamiento;
  late Animation<double> _animacionOpacidadFuegos;

  // Estados de la animacion
  bool _mostrarCarga = true;
  bool _mostrarPerfil = false;
  bool _mostrarTexto = false;
  bool _mostrarFuegosArtificiales = false;

  // Controlar si las animaciones Lottie se han cargado
  bool _lottie1Cargado = false;
  bool _lottie2Cargado = false;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores y animaciones
    _inicializarControladores();
    _iniciarSecuenciaAnimacion();
  }

  // Metodo para iniciar los controladores
  void _inicializarControladores() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controlador y animacion para efecto de escala (golpe)
    _controladorEscala = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controladorDesvanecimiento = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _controladorOpacidadFuegos = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animacion de desvanecimiento para el texto
    _animacionDesvanecimiento = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Secuencia de escala para el perfil (efecto de rebote)
    _animacionEscala = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 2.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 2.0, end: 0.95).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 15,
      ),
    ]).animate(_controladorEscala);

    // Animacion para desplazar el texto de abajo a arriba
    _animacionDesplazamiento = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controladorDesvanecimiento,
      curve: Curves.easeOutBack,
    ));

    // Animacion opacidad fuegos artificiales
    _animacionOpacidadFuegos = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controladorOpacidadFuegos,
      curve: Curves.easeInQuart,
    ));
  }

  // Metodo para sencuenciar la aparicion de los elementos animados
  void _iniciarSecuenciaAnimacion() async {
  try {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      // Ocultar carga
      _mostrarCarga = false;
      // Mostrar perfil
      _mostrarPerfil = true;
    });

    // Iniciar la animacion de escala
    _controladorEscala.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      // Mostrar los fuegos artificiales
      _mostrarFuegosArtificiales = true;
    });
    // Iniciar la animacion de opacidad de los fuegos
    _controladorOpacidadFuegos.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      // Mostrar los textos de bienvenida
      _mostrarTexto = true;
    });
    _fadeController.forward();
    _controladorDesvanecimiento.forward();

    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    // Finalizar la animacion
    widget.onAnimacionCompleta();
  } catch (e) {
    // Finalizar la animacion si da error
    if (mounted) widget.onAnimacionCompleta();
  }
}

  // Limpiar controladores al destruir el widget
  @override
  void dispose() {
    _fadeController.dispose();
    _controladorEscala.dispose();
    _controladorDesvanecimiento.dispose();
    _controladorOpacidadFuegos.dispose();
    _controladorLottie1?.dispose();
    _controladorLottie2?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores del fondo segun el tema
    final coloresGradiente = isDark
    ? [
        custom.contenedor ?? Color.fromRGBO(48, 48, 48, 1),
        custom.contenedor ?? Color.fromRGBO(48, 48, 48, 1),
        custom.contenedor ?? Color.fromRGBO(48, 48, 48, 1),
      ]
    : [
        Color(0xFFe8f2ff), // Azul muy claro - cielo diurno
        Color(0xFFf0f7ff), // Azul blanquecino intermedio
        Color(0xFFfafcff), // Casi blanco con tinte azul
        Color(0xFFffffff), // Blanco puro base
      ];

    return Scaffold(
      backgroundColor: custom.contenedor,
      body: Stack(
        children: [
          // Fondo con gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: coloresGradiente,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Fuegos artificiales y confeti con animaciones de Lottie
          if (_mostrarFuegosArtificiales)
            AnimatedBuilder(
              animation: _animacionOpacidadFuegos,
              builder: (context, child) {
                return Opacity(
                  opacity: _animacionOpacidadFuegos.value,
                  child: Stack(
                    children: [
                      // Animacion 1 (fuegos artificiales)
                      Positioned(
                        top: 100,
                        right: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: 450,
                            height: 450,
                            child: Lottie.asset(
                              'assets/animaciones/AnimacionFuegosArtificiales2.json',
                              repeat: true,
                              animate: true,
                              fit: BoxFit.cover,
                              frameRate: FrameRate.max,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                              onLoaded: (composition) {
                                if (mounted) {
                                  setState(() {
                                    _lottie1Cargado = true;
                                  });
                                  _controladorLottie1 = AnimationController(
                                    vsync: this,
                                    duration: composition.duration,
                                  );
                                  _controladorLottie1?.repeat();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // Animacion 2 (fuegos artificiales)
                      Positioned(
                        bottom: 420,
                        left: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: 420,
                            height: 420,
                            child: Lottie.asset(
                              'assets/animaciones/AnimacionFuegosArtificiales1.json',
                              repeat: true,
                              animate: true,
                              fit: BoxFit.contain,
                              frameRate: FrameRate.max,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                              onLoaded: (composition) {
                                if (mounted) {
                                  setState(() {
                                    _lottie2Cargado = true;
                                  });
                                  _controladorLottie2 = AnimationController(
                                    vsync: this,
                                    duration: composition.duration,
                                  );
                                  _controladorLottie2?.repeat();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // Animacion 3 (confeti)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: Lottie.asset(
                              'assets/animaciones/AnimacionConfeti.json',
                              repeat: true,
                              animate: true,
                              fit: BoxFit.cover,
                              frameRate: FrameRate.max,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) {
                                return Container();
                              },
                              onLoaded: (composition) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_mostrarCarga) ...[
                  LoadingAnimationWidget.threeArchedCircle(
                    color: custom.colorEspecial,
                    size: 80,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Creando tu perfil...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: custom.bordeContenedor.withAlpha(115),
                    ),
                  ),
                ],
                // Mostrar el perfil y el texto
                if (_mostrarPerfil) ...[
                  AnimatedBuilder(
                    animation: _controladorEscala,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animacionEscala.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: custom.colorEspecial,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: custom.colorEspecial.withAlpha(77),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.blue.withAlpha(51),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: widget.imagenPerfilUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.imagenPerfilUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: custom.bordeContenedor.withAlpha(115),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: custom.bordeContenedor.withAlpha(115),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: custom.bordeContenedor.withAlpha(115),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Mostrar texto de bienvenida
                  if (_mostrarTexto) ...[
                    SlideTransition(
                      position: _animacionDesplazamiento,
                      child: FadeTransition(
                        opacity: _animacionDesvanecimiento,
                        child: Column(
                          children: [
                            Text(
                              '¡Bienvenido a Petlink!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: custom.bordeContenedor,
                                shadows: isDark
                                ? [
                                    // Modo oscuro: sombras oscuras para texto blanco
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 6,
                                      color: Colors.black.withValues(alpha: 0.8),
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 12,
                                      color: Colors.black.withValues(alpha: 0.6),
                                    ),
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 8,
                                      color: Colors.grey.shade800.withValues(alpha: 0.7),
                                    ),
                                  ]
                                : [
                                    // Modo claro: sombras azules
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 6,
                                      color: custom.colorEspecial,
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 12,
                                      color: custom.colorEspecial.withValues(alpha: 0.4),
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                      color: custom.contenedor.withValues(alpha: 0.2),
                                    ),
                                  ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '@${widget.nombreUsuario}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: custom.bordeContenedor,
                                shadows: isDark
                                ? [
                                    // Modo oscuro: sombras oscuras para contraste
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 4,
                                      color: Colors.black.withValues(alpha: 0.8),
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 3),
                                      blurRadius: 8,
                                      color: Colors.black.withValues(alpha: 0.5),
                                    ),
                                  ]
                                : [
                                    // Modo claro: sombras azules
                                    Shadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 4,
                                      color: custom.colorEspecial,
                                    ),
                                    Shadow(
                                      offset: const Offset(0, 3),
                                      blurRadius: 8,
                                      color: custom.colorEspecial.withValues(alpha: 0.4),
                                    ),
                                  ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
