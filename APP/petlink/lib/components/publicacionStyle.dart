import 'package:flutter/material.dart';
import 'dart:ui' as ui; // PARA TRABAJAR CON IMÁGENES Y CALCULAR SU ALTURA
import 'dart:io'; // PARA CONTROLAR EL DISPOSITIVO
import 'package:cached_network_image/cached_network_image.dart'; // DESCARGA CON CACHÉ
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

// CLASES
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/ComentariosPage.dart';
import 'package:petlink/screens/UserPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/screens/Secondary/PhotoViewer.dart';

class PublicacionStyle extends StatefulWidget {
  final Publicacion publicacion;
  final bool isComentariosPage;
  final VoidCallback? onTapComentariosPage;
  const PublicacionStyle({super.key, required this.publicacion, this.isComentariosPage = false, this.onTapComentariosPage});

  @override
  State<PublicacionStyle> createState() => _PublicacionStyleState();
}

class _PublicacionStyleState extends State<PublicacionStyle> with TickerProviderStateMixin{ 
  late final AnimationController _likeDoubleTapController = AnimationController(vsync: this); // Controlador para animación de like del doble toque
  late final AnimationController _likeButtonController = AnimationController(vsync: this);
  bool isLikeAnimationVisible = false;

  // Atributos para la imagen
  double? imageHeight; // Altura de la imagen cargada
  double maxHeight = (Platform.isAndroid || Platform.isIOS) ? 325 : 500; // Máxima altura permitida si la imagen es muy alta
  
  // METODOS

  // Calcula dinámicamente la altura real de una imagen a partir de su ImageProvider
  void _resolverAlturaIMG(ImageProvider provider) {
    final stream = provider.resolve(const ImageConfiguration()); // resolve --> Convierte en "ImageStream"
    // Añade el listener
    stream.addListener(
      // Espera a que se cargue la imagen
      ImageStreamListener((info, _) { //
        final ui.Image img = info.image; // Obtiene la imagen cargada
        double altura = imageHeight = img.height.toDouble(); // Convierte la altura a double
        // Si la altura es mayor a la máxima permitida, pilla la altura máxima
        if (altura > maxHeight) {
          altura = maxHeight;
        }
        // Si no... Si el widget no está montado todavía solo ajusta la altura
        if (!mounted) {
          imageHeight = altura;
        } else {
          // Si ya está montado / creado, hace un setState para reconstruir.
          setState(() {
            imageHeight = altura;
          });
        }
      }),
    );
  }

  // Método para calcular el tiempo transcurrido desde la publicación. (FECHA)
  String tiempoTranscurrido(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return '1 segundo';
    } else if (diferencia.inMinutes < 60) {
      return '${diferencia.inMinutes} minuto${diferencia.inMinutes == 1 ? '' : 's'}';
    } else if (diferencia.inHours < 24) {
      return '${diferencia.inHours} hora${diferencia.inHours == 1 ? '' : 's'}';
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
        setState(() {
          isLikeAnimationVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _likeDoubleTapController.dispose();
    _likeButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // PUBLICACION
    final publi = widget.publicacion; 

    // PREPARAR LA FECHA
    DateTime fecha = DateTime.parse(publi.fecha).toLocal();
    String haceCuanto = tiempoTranscurrido(fecha);

    //TEMAS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    // IR PREPARANDO IMAGEN
    final imageProvider = CachedNetworkImageProvider(publi.urlImagen); // URL DE LA IMAGEN
    _resolverAlturaIMG(imageProvider);

    // INTERFAZ
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (!widget.isComentariosPage) {
              final wasMounted = mounted;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComentariosPage(publicacion: publi),
                ),
              );
              if (!wasMounted || !mounted) return;
              setState(() {
                // refrescar
              });
            } else {
              widget.onTapComentariosPage?.call();
            }
          },
          // CONTENEDOR PRINCIPAL
          child: Container(
            margin: EdgeInsets.all((!widget.isComentariosPage) ? 15 : 0),
            decoration: BoxDecoration(
              color: custom.contenedor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                if (!widget.isComentariosPage)
                BoxShadow(
                  color: custom.sombraContenedor,
                  blurRadius: 10,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------------------------------------------
                // IMAGEN PERFIL / NOMBRE / USUARIO / FECHA
                Container(
                  padding: EdgeInsets.only(bottom: 10, right: 20),
                  margin: EdgeInsets.only(
                    bottom: 10,
                    left: 25,
                    top: 20,
                    right: 10,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(idUsuario: publi.uuidPubli)));
                    },
                    child: Row(
                      children: [
                        // IMAGEN DE PERFIL
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: CachedNetworkImageProvider(publi.imagenPerfil),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NOMBRE Y FECHA
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(publi.nombre), Text(haceCuanto, style: TextStyle(color: Colors.grey.shade500),)],
                              ),
                              SizedBox(height: 1),
                              // USUARIO CON CONTENEDOR
                              IntrinsicWidth(
                                child: Container(
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
                                        publi.usuario,
                                        style: TextStyle(color: custom.contenedor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                // --------------------------------------------------------------------------------------
                // TEXTO DE LA PUBLICACIÓN
                if (publi.texto.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 25, bottom: 20, right: 25),
                  child: Text(publi.texto),
                ),
          
                // --------------------------------------------------------------------------------------
                // IMAGEN PUBLICACIÓN
                Container(
                  width: double.infinity,
                  height: imageHeight,
                  margin: EdgeInsets.only(left: 25, right: 25),
                  child: GestureDetector(
                    // DOUBLE TAP --> ANIMACIÓN LIKE
                    onDoubleTap: () async{
                      if (await Seguridad.canInteract(context)){
                        _likeDoubleTapController.forward(from: 0.0); // Reproducir animación
                        setState(() {
                          if (!publi.liked){
                            publi.liked = true;
                            publi.likes++;
                            Publicacion.darLike(context, publi.id.toString());
                          }
                        });
                      }
                    },
                    // UN TAP --> VISUALIZADOR DE IMÁGENES
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PhotoViewer(publicacion: publi),
                        ),
                      ).then((_){
                        setState(() {
                          // Reconstruimos en busca de cambios
                        });
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // CARGAR IMAGEN
                        Hero(
                          tag: imageProvider.url,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: imageProvider.url,
                              placeholder:
                                  (context, url) => Container(
                                    color: tema.surface,
                                    child: Center(
                                      child: Icon(
                                        Icons.pets_rounded,
                                        color: custom.colorEspecial,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      Icon(Icons.error_outline),
                              fit: BoxFit.cover,
                              width: (Platform.isAndroid || Platform.isIOS) ? 400 : 600,
                              height: (Platform.isAndroid || Platform.isIOS) ? 400 : 600,
                              fadeInDuration: Duration(milliseconds: 300),
                              fadeOutDuration: Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                        // Animación like
                        Lottie.asset(
                          "assets/animaciones/like_doubleTap.json",
                          width: 200,
                          height: 200,
                          repeat: false,
                          animate: false,
                          onLoaded: (composition) {
                            _likeDoubleTapController.duration = composition.duration;
                          },
                          controller: _likeDoubleTapController
                        )
                      ],
                    ),
                  ),
                ),
          
                // --------------------------------------------------------------------------------------
                // LIKES Y COMENTARIOS
                Container(
                  margin: EdgeInsets.only(left: 25, right: 25, bottom: 8, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  // Primero comprueba que está login con su respectivo diálogo, si puede entonces suma el like a nivel local
                                  // Y bien puede guardar el like en la BD o borrarlo de la BD
                                  if (await Seguridad.canInteract(context)){
                                    setState(() {
                                      // No like --> LIKE
                                      if (!publi.liked) {
                                        isLikeAnimationVisible = true;
                                        _likeButtonController.forward(from: 0.0);
                                        publi.liked = true;
                                        publi.likes++;
                                        Publicacion.darLike(context, publi.id.toString());
                                      } else {
                                        // LIKE --> No Like
                                        publi.liked = false;
                                        publi.likes--;
                                        Publicacion.quitarLike(context, publi.id.toString());
                                      }
                                    });
                                  }
                                },
                                icon: (!publi.liked)
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
                                child: Text(publi.likes.toString(), style: TextStyle(color: ((!publi.liked) ? tema.primary : Colors.redAccent), fontSize: 16),)
                              ), // NUM LIKES
                            ],
                          ),
                          SizedBox(width: 20),
                          // COMENTARIOS
                          Icon(Icons.chat_bubble_outline_rounded, size: 25),
                          SizedBox(width: 8),
                          Text(publi.numComentarios.toString(), style: TextStyle(fontSize: 16)), // NUM COMENTARIOS
                        ],
                      ),
                      // COMPARTIR
                      IconButton(
                        onPressed: (){
                          Publicacion.compartir(publi);
                        }, 
                        icon: Icon(Icons.share, size: 25,),
                        color: tema.primary,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
