import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:marquee/marquee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TarjetaRazaStyle extends StatefulWidget {
  final String nombreRaza;
  final String rutaImagen;

  // Accion a ejecutar cuando se pulse la tarjeta
  final VoidCallback onTap;

  const TarjetaRazaStyle({
    super.key,
    required this.nombreRaza,
    required this.rutaImagen,
    required this.onTap,
  });

  @override
  State<TarjetaRazaStyle> createState() => _TarjetaRazaStyleState();
}

class _TarjetaRazaStyleState extends State<TarjetaRazaStyle> with TickerProviderStateMixin {

  late var custom =Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  final supabase = Supabase.instance.client;

  // Animaciones
  late AnimationController _controladorAnimacion;
  late AnimationController _controladorAnimacionFavorito;
  late Animation<double> _animacionEscala;
  late Animation<double> _animacionEscalaFavorito;
  late Animation<double> _animacionRotacionFavorito;
  late Animation<Color?> _animacionColorFavorito;

  late Color colorTarjeta;
  bool esFavorito = false;
  bool _mostrarMarquee = false;

  // Lista de colores para el fondo de las tarjetas
  final List<Color> colores = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.lightBlue,
    Colors.indigoAccent,
    Colors.lime,
    Colors.pink,
    Colors.blue,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();

    // Inicializa si es favorito consultando la base
    _verificarFavorito();

    // Animaciones para interaccionar con la tarjeta
    _controladorAnimacion = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _animacionEscala = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeInOut),
    );

    // Animaciones para boton de favorito
    _controladorAnimacionFavorito = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _animacionEscalaFavorito = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controladorAnimacionFavorito,
        curve: Curves.elasticOut,
      ),
    );

    _animacionRotacionFavorito = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controladorAnimacionFavorito,
        curve: Curves.easeInOut,
      ),
    );

    // Seleccionar el color aleatorio de la tarjeta
    final random = Random();
    colorTarjeta = colores[random.nextInt(colores.length)];

    // Iniciar el delay de marquee
    _iniciarDelayMarquee();
  }

  // Mantener el estado de favorito sincronizado cuando el widget padre se reconstruye
  @override
  void didUpdateWidget(covariant TarjetaRazaStyle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Siempre verifica si sigue siendo favorito al actualizar el widget
    _verificarFavorito();
  }

  // Metodo para verificar si una raza es favorito
  void _verificarFavorito() async {
    final userId = SupabaseAuthService.id;

    // Verificar si el usuario es null o esta vacio
    if (userId == null || userId.isEmpty) return;

    try {
      // Consulta a la BD
      final response = await supabase
          .from('raza_favorito')
          .select()
          .eq('id_usuario', userId)
          .eq('raza', widget.nombreRaza)
          .limit(1);

      final existeFavorito = response != null && (response as List).isNotEmpty;

      if (mounted) {
        setState(() {
          esFavorito = existeFavorito;
          if (esFavorito) {
            _controladorAnimacionFavorito.value = 1.0;
          }
        });
      }
    } catch (e) {
      print('Error al verificar favorito: $e');
    }
  }

  // Temporizador de dos segundos antes de activar el marquee
  void _iniciarDelayMarquee() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _mostrarMarquee = true;
        });
      }
    });
  }

  // Inicializa la animacion de cambio de color del icono de favorito
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tema = Theme.of(context).colorScheme;

    _animacionColorFavorito = ColorTween(
      begin: tema.outline,
      end: Colors.red.shade600,
    ).animate(
      CurvedAnimation(
        parent: _controladorAnimacionFavorito,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    _controladorAnimacionFavorito.dispose();
    super.dispose();
  }

  // Alternar el estado favorito de la raza
  void _alternarFavorito() async {
    final userId = SupabaseAuthService.id;

    // Si no esta logueado no puede agregar a favoritos
    if (userId == null || userId.isEmpty) {
      MensajeSnackbar.mostrarInfo(
        context,
        'Debes iniciar sesión para agregar favoritos',
      );
      return;
    }

    final nuevoEstado = !esFavorito;

    setState(() {
      esFavorito = nuevoEstado;
    });

    _controladorAnimacionFavorito.reset();
    if (nuevoEstado) {
      _controladorAnimacionFavorito.forward();
    } else {
      _controladorAnimacionFavorito.reverse();
    }

    try {
      if (nuevoEstado) {
        // Insertar favorito en la BD
        await supabase.from('raza_favorito').insert({
          'id_usuario': userId,
          'raza': widget.nombreRaza,
        });
      } else {
        // Eliminar favorito en DB
        await supabase
            .from('raza_favorito')
            .delete()
            .eq('id_usuario', userId)
            .eq('raza', widget.nombreRaza);
      }
    } catch (e) {
      // Ejecutar la animacion dependiendo de si da error o no
      if (mounted) {
        setState(() {
          esFavorito = !nuevoEstado;
          if (esFavorito) {
            _controladorAnimacionFavorito.forward();
          } else {
            _controladorAnimacionFavorito.reverse();
          }
        });
      }
      MensajeSnackbar.mostrarInfo(context, 'Error al actualizar favoritos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animacionEscala,
      builder: (context, child) {
        // Animacion de escala para cuando se pulse la tarjeta
        return Transform.scale(
          scale: _animacionEscala.value,
          child: GestureDetector(
            // Ejecutar la animacion al presionar
            onTapDown: (_) => _controladorAnimacion.forward(),
            onTapUp: (_) {
              // Revertir la animacion al soltar
              _controladorAnimacion.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controladorAnimacion.reverse(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Contenedor principal
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 11, vertical: 11),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [custom.contenedor, custom.contenedor],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    // Sombras tarjeta principal
                    boxShadow: [
                      BoxShadow(
                        color: custom.sombraContenedor,
                        blurRadius: 4,
                        offset: Offset(-3, 0),
                      ),
                      BoxShadow(
                        color: custom.sombraContenedor,
                        blurRadius: 4,
                        offset: Offset(0, 5),
                      ),
                      BoxShadow(
                        color: custom.sombraContenedor,
                        blurRadius: 4,
                        offset: Offset(3, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Stack(
                      children: [
                        // Imagen del perro
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorTarjeta.withValues(alpha: 0.2),
                                  colorTarjeta.withValues(alpha: 0.1),
                                  tema.primaryContainer.withValues(alpha: 0.12),
                                ],
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.rutaImagen,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder:
                                  (context, url) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          tema.primaryContainer.withValues(alpha: 0.2),
                                          tema.primaryContainer.withValues(alpha: 0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: tema.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                              // Si hay un error en la imagen mostrarlo
                              errorWidget:
                                  (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          tema.errorContainer.withValues(
                                            alpha: 0.3,
                                          ),
                                          tema.errorContainer.withValues(
                                            alpha: 0.1,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pets,
                                          size: 36,
                                          color: tema.onErrorContainer
                                              .withValues(alpha: 0.7),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Error al cargar',
                                          style: TextStyle(
                                            color: tema.onErrorContainer,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                color: tema.primary.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Boton de favorito animado
                Positioned(
                  top: 15,
                  right: 18,
                  child: GestureDetector(
                    onTap: _alternarFavorito,
                    child: AnimatedBuilder(
                      animation: _controladorAnimacionFavorito,
                      builder: (context, child) {
                        final scale =
                            1.0 + (_animacionEscalaFavorito.value - 1.0) * 0.5;
                        final rotation =
                            esFavorito
                                ? sin(
                                      _animacionRotacionFavorito.value * pi * 4,
                                    ) *
                                    0.1
                                : 0.0;
                        return Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: scale,
                            child: Transform.rotate(
                              angle: rotation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Efecto de brillo
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.red.withValues(
                                            alpha:
                                                esFavorito
                                                    ? 0.4 *
                                                        _controladorAnimacionFavorito
                                                            .value
                                                    : 0,
                                          ),
                                          Colors.red.withValues(
                                            alpha:
                                                esFavorito
                                                    ? 0.1 *
                                                        _controladorAnimacionFavorito
                                                            .value
                                                    : 0,
                                          ),
                                          Colors.transparent,
                                        ],
                                        stops: [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                  // Icono corazon
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors:
                                              esFavorito
                                                  ? [
                                                    Color(0xFFFF7F7F),
                                                    Color(0xFFE34234),
                                                  ]
                                                  : [
                                                    Colors.red.shade200,
                                                    Colors.red.shade400,
                                                  ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: Icon(
                                      esFavorito
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Efecto al marcar como favorito
                                  if (esFavorito)
                                    Positioned(
                                      top: 4,
                                      left: 8,
                                      child: Opacity(
                                        opacity:
                                            0.7 *
                                            (1 -
                                                _controladorAnimacionFavorito
                                                    .value),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                blurRadius: 5,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 115,
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: custom.colorEspecial,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: custom.colorEspecial,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tema.shadow.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: widget.nombreRaza,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: tema.onPrimary,
                              ),
                            ),
                            textDirection: TextDirection.ltr,
                          );
                          textPainter.layout();

                          if (textPainter.width <= constraints.maxWidth) {
                            return Center(
                              child: Text(
                                widget.nombreRaza,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: tema.onPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            if (!_mostrarMarquee) {
                              return Center(
                                child: Text(
                                  widget.nombreRaza,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: tema.onPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                            return Marquee(
                              text: widget.nombreRaza,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: tema.onPrimary,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 20.0,
                              velocity: 20.0,
                              pauseAfterRound: Duration(seconds: 2),
                              fadingEdgeStartFraction: 0.15,
                              fadingEdgeEndFraction: 0.1,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
