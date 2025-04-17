import 'package:flutter/material.dart';
import 'dart:ui' as ui; // PARA TRABAJAR CON IMÁGENES Y CALCULAR SU ALTURA
import 'dart:io'; // PARA CONTROLAR EL DISPOSITIVO
import 'package:cached_network_image/cached_network_image.dart'; // DESCARGA CON CACHÉ
import 'package:petlink/entidades/seguridad.dart';

// CLASES
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/screens/Secondary/PhotoViewer.dart';
import 'package:petlink/components/animacionLike.dart';

class PublicacionStyle extends StatefulWidget {
  final Publicacion publicacion;
  const PublicacionStyle({super.key, required this.publicacion});

  @override
  State<PublicacionStyle> createState() => _PublicacionStyleState();
}

class _PublicacionStyleState extends State<PublicacionStyle> { 
  final GlobalKey<AnimacionLikeState> likeKey = GlobalKey(); // Key para la animación de like

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
      return 'Hace unos segundos';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes == 1 ? '' : 's'}';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours == 1 ? '' : 's'}';
    } else {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays == 1 ? '' : 's'}';
    }
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
        // CONTENEDOR PRINCIPAL
        Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: custom.contenedor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
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
                  right: 25,
                ),
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
                            children: [Text(publi.nombre), Text(haceCuanto)],
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
                      likeKey.currentState?.onDoubleTap();
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
                      AnimacionLike(key: likeKey), // ANIMACION LIKE
                    ],
                  ),
                ),
              ),

              // --------------------------------------------------------------------------------------
              // LIKES Y COMENTARIOS
              Container(
                margin: EdgeInsets.only(left: 25, bottom: 10, top: 2, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            // Primero comprueba que está login con su respectivo diálogo, si puede entonces suma el like a nivel local
                            // Y bien puede guardar el like en la BD o borrarlo de la BD
                            if (await Seguridad.canInteract(context)){
                              setState(() {
                                publi.liked = !publi.liked;
                                if (publi.liked) {
                                  publi.likes++;
                                  Publicacion.darLike(context, publi.id.toString());
                                } else {
                                  publi.likes--;
                                  Publicacion.quitarLike(context, publi.id.toString());
                                }
                              });
                            }
                          },
                          icon: (!publi.liked)
                              ? Icon(Icons.favorite_border_rounded, size: 25)
                              : Icon(Icons.favorite_rounded, size: 25, color: Colors.redAccent,)
                        ),
                        Text(publi.likes.toString(), style: TextStyle(color: ((!publi.liked) ? tema.primary : Colors.redAccent), fontSize: 16),), // NUM LIKES
                        SizedBox(width: 20),
                        // COMENTARIOS
                        IconButton(
                          onPressed: () {
                            print("COMENTARIO");
                          },
                          icon: Icon(Icons.chat_bubble_outline_rounded, size: 25),
                        ),
                        Text("46", style: TextStyle(fontSize: 16)), // NUM COMENTARIOS
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
      ],
    );
  }
}
