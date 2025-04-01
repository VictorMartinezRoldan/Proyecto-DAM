import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // PARA MOSTRAR LA IMAGEN DESDE CACHÉ
import 'package:petlink/entidades/publicacion.dart';
import 'package:photo_view/photo_view.dart'; // EL VISOR DE IMÁGENES
import 'package:permission_handler/permission_handler.dart'; // PARA SOLICITAR PERMISOS PARA GUARDAR LA IMAGEN
import 'package:flutter_file_downloader/flutter_file_downloader.dart'; // PARA DESCARGAR LA IMAGEN

class PhotoViewer extends StatefulWidget {
  final Publicacion publicacion;
  const PhotoViewer({
    super.key, required this.publicacion
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  // MÉTODO PARA PEDIR PERMISOS
  Future<bool> pedirPermisos() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      return false;
    } else {
      return true;
    }
  }

  void guardarImagen(BuildContext context, String url) {
    if (pedirPermisos() == false) {
      if(pedirPermisos() == false) {
        mostrarMensaje(context, "Se necesitan permisos", 270);
        return;
      }
    }
    FileDownloader.downloadFile(
      url: url,
      onDownloadCompleted: (path) => mostrarMensaje(context, "Imagen guardada", 200),
      onDownloadError: (errorMessage) => mostrarMensaje(context, "Error al guardarla", 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool soloTexfield = (MediaQuery.of(context).viewInsets.bottom != 0);
    return Scaffold(
      extendBodyBehindAppBar: true, // El appBar se fusiona con el body no hace margin
      extendBody: true,
      resizeToAvoidBottomInset: true, // Esto es clave
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        // Icono para descargar con el menú
        actions: [
          PopupMenuButton(
            color: Colors.grey.shade900,
            position: PopupMenuPosition.under,
            menuPadding: EdgeInsets.all(0),
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "DESCARGA") {
                guardarImagen(context, widget.publicacion.urlImagen);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: "DESCARGA",
                    child: Row(
                      children: [
                        Icon(Icons.save_alt_rounded),
                        SizedBox(width: 7),
                        Text("Guardar", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        // Parte de imagen de perfil, nombre y usuario
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: Container(
            //color: Colors.amber,
            padding: EdgeInsets.only(bottom: 10, right: 20),
            margin: EdgeInsets.only(left: 15, right: 25),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: CachedNetworkImageProvider(widget.publicacion.imagenPerfil),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.publicacion.nombre, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 1),
                      IntrinsicWidth(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 7,
                            right: 7,
                            bottom: 1,
                            top: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.pets, size: 18, color: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                widget.publicacion.usuario,
                                style: TextStyle(color: Colors.black),
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
      ),
      // VISUALIZADOR DE IMÁGENES
      body: Center(
        child: GestureDetector(
          onTap: () {
            if (soloTexfield) {
              FocusScope.of(context).unfocus(); // Esconder el teclado
            } else {
              Navigator.pop(context); // Volver
            }
          },
          child: Hero(
            tag: widget.publicacion.urlImagen,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(widget.publicacion.urlImagen),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Esto levanta el container
          ),
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                // PRINCIPAL
                children: [
                  Visibility(
                    visible: !soloTexfield,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.publicacion.liked = !widget.publicacion.liked;
                              if (widget.publicacion.liked) {
                                widget.publicacion.likes++;
                              } else {
                                widget.publicacion.likes--;
                              }
                            });
                          },
                          icon: (!widget.publicacion.liked)
                            ? Icon(Icons.favorite_border_rounded, size: 25, color: Colors.white,)
                            : Icon(Icons.favorite_rounded, size: 25, color: Colors.redAccent,)
                          ),
                          Text(widget.publicacion.likes.toString(), style: TextStyle(color: ((!widget.publicacion.liked) ? Colors.white : Colors.redAccent), fontSize: 16),), // NUM LIKES
                          SizedBox(width: 20),  
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: (soloTexfield) ? null : 1,
                      minLines: 1,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Escribir comentario...",
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1)
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1)
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1)
                        ),
                      ),
                    ),
                  ),

                  // BOTON ENVIAR
                  Visibility(
                    visible: soloTexfield,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                        onPressed: (){}, 
                        icon: Icon(Icons.send, color: Colors.black),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // COMPARTIR
                  Visibility(
                    visible: !soloTexfield,
                    child: IconButton(
                      onPressed: (){
                        Publicacion.compartir(widget.publicacion);
                      }, 
                      icon: Icon(Icons.share, size: 25,),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MÉTODO PARA CREAR Y MOSTRAR UN SNACKBAR PERSONALIZADO PARA ERRORES Y CONFIRMACIÓN DE DESCARGA
  void mostrarMensaje(BuildContext context, String texto, double size) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: size,
        content: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, color: Colors.black),
              SizedBox(width: 10),
              Flexible(
                child: Text(texto, style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
