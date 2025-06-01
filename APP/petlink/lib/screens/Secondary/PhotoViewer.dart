// BIBLIOTECAS
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // PARA MOSTRAR LA IMAGEN DESDE CACHÉ
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:photo_view/photo_view.dart'; // EL VISOR DE IMÁGENES
import 'package:permission_handler/permission_handler.dart'; // PARA SOLICITAR PERMISOS PARA GUARDAR LA IMAGEN
import 'package:flutter_file_downloader/flutter_file_downloader.dart'; // PARA DESCARGAR LA IMAGEN

// CLASES
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/screens/Secondary/ComentariosPage.dart';

class PhotoViewer extends StatefulWidget {
  final Publicacion publicacion;
  const PhotoViewer({
    super.key, required this.publicacion
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> with TickerProviderStateMixin {

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
        MensajeSnackbar.mostrarError(context, "Se necesitan permisos");
        return;
      }
    }
    FileDownloader.downloadFile(
      url: url,
      onDownloadCompleted: (path) => MensajeSnackbar.mostrarExito(context, "Imagen guardada"),
      onDownloadError: (errorMessage) => MensajeSnackbar.mostrarError(context, "Error al guardarla")
    );
  }

  @override
  void initState() {
    super.initState();
    ComentariosPage.focusScopeError = FocusScopeNode(); // REINICIAR ARBOL DE FocusScope
  }

  @override
  Widget build(BuildContext context) {
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
              } else if (value == "COMPARTIR") {
                Publicacion.compartir(widget.publicacion);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: "DESCARGA",
                    child: Row(
                      children: [
                        Icon(Icons.save_alt_rounded),
                        SizedBox(width: 10),
                        Text("Guardar", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "COMPARTIR",
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 10),
                        Text("Compartir", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
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
            Navigator.pop(context); // Volver
          },
          child: Hero(
            tag: widget.publicacion.urlImagen,
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 1.5,
              imageProvider: CachedNetworkImageProvider(widget.publicacion.urlImagen),
            ),
          ),
        ),
      ),
    );
  }
}
