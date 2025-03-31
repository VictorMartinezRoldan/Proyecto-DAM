import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // PARA MOSTRAR LA IMAGEN DESDE CACHÉ
import 'package:photo_view/photo_view.dart'; // EL VISOR DE IMÁGENES
import 'package:permission_handler/permission_handler.dart'; // PARA SOLICITAR PERMISOS PARA GUARDAR LA IMAGEN
import 'package:flutter_file_downloader/flutter_file_downloader.dart'; // PARA DESCARGAR LA IMAGEN

class PhotoViewer extends StatelessWidget {
  final String urlPhoto;
  final String urlProfile;
  final String nombre;
  final String usuario;
  const PhotoViewer({
    super.key,
    required this.urlPhoto,
    required this.urlProfile,
    required this.nombre,
    required this.usuario,
  });

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
    return Scaffold(
      extendBodyBehindAppBar: true, // El appBar se fusiona con el body no hace margin
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
                guardarImagen(context, urlPhoto);
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
                  backgroundImage: CachedNetworkImageProvider(urlProfile),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: TextStyle(color: Colors.white)),
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
                                usuario,
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
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: urlPhoto,
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(urlPhoto),
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
