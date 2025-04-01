import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class Publicacion {
  // ATRIBUTOS DE LAS PUBLICACIONES
  final int id;
  final String imagenPerfil;
  final String nombre;
  final String usuario;
  final String texto;
  final String fecha; // FORMATEAR
  final String urlImagen;
  int likes;
  bool liked = false;
  // comentarios

  // CONSTRUCTOR 
  Publicacion({
    required this.id,
    required this.imagenPerfil,
    required this.nombre,
    required this.usuario,
    required this.texto,
    required this.fecha,
    required this.urlImagen,
    required this.likes,
  });

  // LISTA DE PUBLICACIONES CARGADAS PARA NO VOLVER A MOSTRAR
  static List<Publicacion> publicacionesExistentes = [];

  // MÉTODO QUE SOLICITA INFORMACIÓN ACERCA DE UNA PUBLICACIÓN
  static Future<List<Publicacion>> solicitarPublicaciones(int num_publicaciones) async {
    List<Publicacion> publicaciones = []; // LISTA DE PUBLICACIONES A ENVIAR
    final supaClient = Supabase.instance.client;
    final response = await supaClient.rpc(
      'obtener_publicaciones_aleatorias', // LLAMAMOS A UNA FUNCIÓN DENTRO DE LA BD CON UNA CONSULTA AVANZADA
      params: {'limit_count': num_publicaciones}
    );

    if (response == null || response.isEmpty) {
      print("NO HAY DATOS");
      return publicaciones; // DEVUELVE LAS PUBLICACIONES VACÍAS
    } else {
      // SI HAY DATOS, BUCLE POR CADA PUBLICACIÓN RECIBIDA
      for (int i = 0; i < response.length; i++) {
        var datos = response[i]; // EXTRAIGO LA INFORMACIÓN
        // CREO EL OBJETO
        Publicacion newPubli = Publicacion(
            id: datos["id"],
            imagenPerfil: datos["imagen_perfil"],
            nombre: datos["nombre"],
            usuario: datos["usuario"],
            texto: datos["texto"],
            fecha: datos["fecha_publicacion"],
            urlImagen: datos["imagen_url"],
            likes: datos["likes"],
        );
        if (publicacionesExistentes.contains(newPubli)){
          // YA EXISTE, NO SE METE
        } else {
          publicacionesExistentes.add(newPubli); // AÑADO AL HISTORIAL
          publicaciones.add(newPubli); // AÑADO A LA LISTA DE PUBLICACIONES A ENVIAR
        }
      }
      return publicaciones;
    }
  }

  // MÉTODO PARA COMPARTIR PUBLICACIÓN
  static Future<void> compartir(Publicacion publi) async {
    // 1. Buscar la imagen en caché o descargarla
    final file = await DefaultCacheManager().getSingleFile(publi.urlImagen);
    
    // 2. Compartir la imagen
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '''
🐶 Mira que perro tan bonito he encontrado en PETLINK! 🐶

📱 PETLINK - La red social para los amantes de los perritos 🐾
Descubre, comparte y aprende sobre todas las razas.
✨¡Únete gratis!✨'''
    );
    // Conoce a ${nombreDelPerro} en PetLink! // RAZA
  }

  // SOBRESCRIBO EL HASHCODE PARA DEFINIR CUANDO 2 PUBLICACIONES SON IGUALES
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Publicacion && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
