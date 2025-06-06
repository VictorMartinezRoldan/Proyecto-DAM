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
import 'package:petlink/screens/Secondary/ComentariosPage.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';

// ignore: must_be_immutable
class ComentarioStyle extends StatefulWidget {
  final GlobalKey<ComentarioStyleState> keyComentario = GlobalKey<ComentarioStyleState>();
  final Comentario comentario;
  final Comentario comentarioPadre;
  final Function(String, Comentario, String) onResponder;
  final Function(ComentarioStyle) onEliminar;
  final Function(Comentario) onVerRespuestas;
  final bool isRespuesta;
  ComentarioStyle({super.key, this.isRespuesta = false, required this.comentario, required this.onResponder, required this.onEliminar, required this.onVerRespuestas, required this.comentarioPadre});

  bool expandirRespuestas = false;

  @override
  State<ComentarioStyle> createState() => ComentarioStyleState();
}

class ComentarioStyleState extends State<ComentarioStyle> with TickerProviderStateMixin{
  bool isLikeAnimationVisible = false;
  late final AnimationController _likeButtonController = AnimationController(vsync: this);
  late final AnimationController _scaleAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 600));

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
      _scaleAnimation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
              widget.comentario.esNuevo = false;
            });
          }
        });

      _scaleAnimation.forward();
    }
  }

  @override void dispose() {
    _likeButtonController.dispose();
    _scaleAnimation.dispose();
    super.dispose();
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

    return ScaleTransition(
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
              if (comentario.usuario == SupabaseAuthService.nombreUsuario && SupabaseAuthService.isLogin.value)
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
                      backgroundColor: custom.contenedor,
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
                            SizedBox(width: (!widget.isRespuesta) ? 10 : 0),
                            if (ComentariosPage.propietario == widget.comentario.usuario)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: custom.fondoSuave,
                                border: Border.all(
                                  color: custom.textoSuave,
                                  width: 2
                                )
                              ),
                              child: Text("Autor", style: TextStyle(color: custom.textoSuave, fontWeight: FontWeight.bold)),
                            ),
                            if (widget.isRespuesta)
                            SizedBox(width: 5),
                            if (widget.isRespuesta)
                            Icon(Icons.keyboard_double_arrow_right_sharp, size: 20, color: custom.colorEspecial),
                            SizedBox(width: (ComentariosPage.propietario == widget.comentario.usuario) ? 5 : 8),
                            if (widget.isRespuesta)
                            Text(comentario.usuarioRespondido!, style: TextStyle(fontWeight: FontWeight.w500)),
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
                            widget.onResponder(comentario.nombre, widget.isRespuesta ? widget.comentarioPadre : comentario, comentario.uuid);
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
                                      widget.isRespuesta ? Comentario.darLikeRespuesta(context, comentario.idRespuesta!) : Comentario.darLikeComentario(context, comentario.idComentario);
                                      
                                    } else {
                                      // LIKE --> No Like
                                      comentario.liked = false;
                                      comentario.likes--;
                                      widget.isRespuesta ? Comentario.quitarLikeRespuesta(context, comentario.idRespuesta!) : Comentario.quitarLikeComentario(context, comentario.idComentario);
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
                      child: !widget.expandirRespuestas ? SizedBox.shrink() : Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...comentario.respuestas
                        ],
                      ),
                    ),
                    // -------------------------------------------------------------
                    // -------------------------------------------------------------
                    // -------------------------------------------------------------
                    // if (!widget.isRespuesta)
                    if (comentario.numRespuestas > 0)
                    Row(
                      children: [
                        if (comentario.numRespuestas > 0 && comentario.numRespuestas - comentario.respuestas.length != 0 || !widget.expandirRespuestas)
                        TextButton (
                          onPressed: () async {
                            if (widget.expandirRespuestas) {
                              await widget.onVerRespuestas(widget.comentario);
                            }
                            setState(() {
                              widget.expandirRespuestas = true;
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
                              Text("Ver ${widget.expandirRespuestas ? comentario.numRespuestas - comentario.respuestas.length : comentario.numRespuestas} respuestas", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 3),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 25)
                            ],
                          ),
                        ),
                        if (comentario.numRespuestas > 0 && comentario.numRespuestas - comentario.respuestas.length != 0 || !widget.expandirRespuestas)
                        SizedBox(width: 15),
                        if (widget.expandirRespuestas)
                        TextButton (
                          onPressed: () {
                            setState(() {
                              widget.expandirRespuestas = false;
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
    );
  }
}