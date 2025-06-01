// BIBLIOTECAS
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petlink/components/mensajeSnackbar.dart';

// CLASES
import 'package:petlink/entidades/comentario.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';

class ComentarioStyle extends StatefulWidget {
  final Comentario comentario;
  final Function(String) onResponder;
  final Function(ComentarioStyle) onEliminar;
  final bool isRespuesta;
  const ComentarioStyle({super.key, this.isRespuesta = false, required this.comentario, required this.onResponder, required this.onEliminar});

  @override
  State<ComentarioStyle> createState() => _ComentarioStyleState();
}

class _ComentarioStyleState extends State<ComentarioStyle> with TickerProviderStateMixin{
  bool _expandirRespuestas = false;
  bool isLikeAnimationVisible = false;
  late final AnimationController _likeButtonController = AnimationController(vsync: this);
  late final AnimationController _scaleAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
  late final AnimationController _fadeAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 1300));

  // Método para calcular el tiempo transcurrido desde la publicación. (FECHA)
  String tiempoTranscurrido(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    if (diferencia.inMinutes == 0) {
      return '${diferencia.inSeconds + 1} s';
    } else if (diferencia.inMinutes < 1) {
      return '${diferencia.inSeconds} s';
    } else if (diferencia.inMinutes < 60) {
      return '${diferencia.inMinutes} m';
    } else if (diferencia.inHours < 24) {
      return '${diferencia.inHours} h';
    } else if (diferencia.inDays <= 30) {
      return '${diferencia.inDays} día${diferencia.inDays == 1 ? '' : 's'}';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return '$meses mes${meses == 1 ? '' : 'es'}';
    } else {
      return DateFormat.yMMMMd().format(fecha);
    }
  }

  @override
  void initState() {
    super.initState();
    _likeButtonController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          isLikeAnimationVisible = false;
        });
      }
    });
    if (widget.comentario.esNuevo) {
      _scaleAnimation.forward();
    }
    _fadeAnimation.forward();
  }

  @override
  Widget build(BuildContext context) {
    //TEMAS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    Comentario comentario = widget.comentario;

    // PREPARAR LA FECHA
    DateTime fecha = DateTime.parse(comentario.fecha).toLocal();
    String haceCuanto = tiempoTranscurrido(fecha);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeAnimation,
        curve: Curves.easeInOut,
      ),
      child: ScaleTransition(
        alignment: Alignment.topCenter,
        scale: Tween<double>(begin: (comentario.esNuevo) ? 0.2 : 1.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _scaleAnimation, 
            curve: Curves.easeInOut,
          )
        ),
        child: GestureDetector(
          onLongPressStart: (posicion) async {
            final tapPosicion = posicion.globalPosition;
            final resultado = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                tapPosicion.dx - 100,
                tapPosicion.dy,
                tapPosicion.dx + 1,
                tapPosicion.dy + 1,
              ),
              constraints: BoxConstraints(
                minWidth: 240
              ),
              color: custom.contenedor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              shadowColor: custom.bordeContenedor,
              items: [
                PopupMenuItem(
                  value: 'copiar',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 10),
                      Text("Copiar")
                    ],
                  )
                ),
                if (comentario.usuario == SupabaseAuthService.nombreUsuario)
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_outlined, color: Colors.redAccent,),
                      SizedBox(width: 10),
                      Text("Eliminar comentario", style: TextStyle(color: Colors.redAccent))
                    ],
                  )
                ),
              ]
            );
            switch (resultado) {
              case 'copiar':
                Clipboard.setData(ClipboardData(text: comentario.texto));
                if (!context.mounted) return;
                MensajeSnackbar.mostrarExito(context, "Comentario copiado");
                break;
              case 'eliminar':
                if (!context.mounted) return;
                await _fadeAnimation.reverse();
                widget.onEliminar(widget);
                break;
              default:
                break;
            }
          },
          child: Container(
            color: custom.contenedor,
            margin: EdgeInsets.only(
              bottom: 15,
              top: !widget.isRespuesta ? 15 : 10,
              left: !widget.isRespuesta ? 15 : 0,
              right: !widget.isRespuesta ? 15 : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: CircleAvatar(
                        backgroundColor: custom.colorEspecial,
                        foregroundColor: custom.contenedor,
                        backgroundImage: CachedNetworkImageProvider(comentario.imagenPerfil),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(comentario.nombre, style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(width: widget.isRespuesta ? 5 : 10),
                              if (!widget.isRespuesta)
                              Container(
                                padding: EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 1,
                                  top: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: custom.colorEspecial,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 18,
                                      color: custom.contenedor,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      comentario.usuario,
                                      style: TextStyle(color: custom.contenedor),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isRespuesta)
                              Icon(Icons.keyboard_double_arrow_right_sharp, size: 20, color: custom.colorEspecial),
                              SizedBox(width: 5),
                              if (widget.isRespuesta)
                              Text("usuario 2", style: TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 7),
                          Text(comentario.texto)
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(haceCuanto),
                          SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              //widget.onResponder(comentario.nombre);
                            }, 
                            style: TextButton.styleFrom(
                              foregroundColor: custom.colorEspecial,
                              minimumSize: Size(100, 25),
                              maximumSize: Size(100, 25),
                              padding: EdgeInsets.zero
                            ),
                            child: Text("Responder", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          Spacer(),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  // Primero comprueba que está login con su respectivo diálogo, si puede entonces suma el like a nivel local
                                  // Y bien puede guardar el like en la BD o borrarlo de la BD
                                  if (await Seguridad.canInteract(context)){
                                    if (!mounted) return;
                                    setState(() {
                                      // No like --> LIKE
                                      if (!comentario.liked) {
                                        isLikeAnimationVisible = true;
                                        _likeButtonController.forward(from: 0.0);
                                        comentario.liked = true;
                                        comentario.likes++;
                                        Comentario.darLike(context, comentario.idComentario);
                                      } else {
                                        // LIKE --> No Like
                                        comentario.liked = false;
                                        comentario.likes--;
                                        Comentario.quitarLike(context, comentario.idComentario);
                                      }
                                    });
                                  }
                                },
                                icon: (!comentario.liked)
                                    ? Icon(Icons.favorite_border_rounded, size: 25)
                                    : Icon(Icons.favorite_rounded, size: 25, color: Colors.redAccent),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
                              Visibility(
                                visible: isLikeAnimationVisible,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Lottie.asset(
                                  "assets/animaciones/like_button.json",
                                  width: 50,
                                  height: 50,
                                  repeat: false,
                                  animate: false,
                                  controller: _likeButtonController,
                                  onLoaded: (composition) {
                                    _likeButtonController.duration = composition.duration;
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 50),
                                child: Text(comentario.likes.toString(), style: TextStyle(color: ((!comentario.liked) ? tema.primary : Colors.redAccent), fontSize: 16),)
                              ), // NUM LIKES
                            ],
                          ),
                          SizedBox(width: 15)
                        ],
                      ),
                      // -------------------------------------------------------------
                      // CONTENEDOR DE RESPUESTAS
                      // -------------------------------------------------------------
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linearToEaseOut,
                        child: !_expandirRespuestas ? SizedBox.shrink() : Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ComentarioStyle(isRespuesta: true, comentario: comentario,),
                            // ComentarioStyle(isRespuesta: true, comentario: comentario),
                          ],
                        ),
                      ),
                      // -------------------------------------------------------------
                      // -------------------------------------------------------------
                      // -------------------------------------------------------------
                      // if (!widget.isRespuesta)
                      if (false)
                      Row(
                        children: [
                          TextButton (
                            onPressed: () {
                              setState(() {
                                _expandirRespuestas = true;
                              });
                            }, 
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              splashFactory: NoSplash.splashFactory
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Ver respuestas", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 3),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 25)
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          if (_expandirRespuestas)
                          TextButton (
                            onPressed: () {
                              setState(() {
                                _expandirRespuestas = false;
                              });
                            }, 
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              splashFactory: NoSplash.splashFactory
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Ocultar", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 3),
                                Icon(Icons.keyboard_arrow_up_rounded, size: 25)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}