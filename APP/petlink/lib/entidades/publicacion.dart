import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/services/supabase_auth.dart';
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
    required this.liked
  });

  // LISTA DE PUBLICACIONES CARGADAS PARA NO VOLVER A MOSTRAR
  static List<Publicacion> publicacionesExistentes = [];
  // MÉTODO QUE SOLICITA INFORMACIÓN ACERCA DE UNA PUBLICACIÓN
  static Future<List<Publicacion>> solicitarPublicaciones(BuildContext context, int num_publicaciones) async {
    List<Publicacion> publicaciones = []; // LISTA DE PUBLICACIONES A ENVIAR
    try {
      final supaClient = Supabase.instance.client;
      final response = await supaClient.rpc(
        'obtener_publicaciones_aleatorias', // LLAMAMOS A UNA FUNCIÓN DENTRO DE LA BD CON UNA CONSULTA AVANZADA
        params: {'limit_count': num_publicaciones, 'usuario_uid' : (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.id : null}
      );

      if (response == null || response.isEmpty) {
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
              liked: datos["liked"]
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
    } catch (e) {
      // SE A PRODUCIDO UN ERROR, PRIMERO COMPROBAMOS DE QUE HAYA CONEXIÓN
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected){
        // Si no tiene conexión a internet...
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return publicaciones;
    }
  }

  // MÉTODO PARA COMPARTIR PUBLICACIÓN
  static Future<void> compartir(Publicacion publi) async {
    // 1. Buscar la imagen en caché o descargarla
    final fileOriginal = await DefaultCacheManager().getSingleFile(publi.urlImagen);
    final tempDir = await getTemporaryDirectory();
    final fileRenombrado = await fileOriginal.copy("${tempDir.path}/petlink.jpg"); // Nombre personalizado
    
    // 2. Compartir la imagen
    await Share.shareXFiles(
      [XFile(fileRenombrado.path)],
      text: '''
🐶 Mira que perro tan bonito he encontrado en PETLINK! 🐶

📱 PETLINK - La red social para los amantes de los perritos 🐾
Descubre, comparte y aprende sobre todas las razas.
✨¡Únete gratis!✨'''
    );
    // Conoce a ${nombreDelPerro} en PetLink! // RAZA
  }

  // Metodo para guardar Likes en la BD
  static Future<void> darLike(BuildContext context, String id_publi) async {
    final supaClient = Supabase.instance.client;
    try {
      final response = await supaClient.from('likes')
        .insert({
          'id_usuario' : SupabaseAuthService.id,
          'id_publicacion' : id_publi
      });
    } catch (e) {
      // ERROR AL DAR LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // Metodo para borrar Likes en la BD
  static Future<void> quitarLike(BuildContext context, String id_publi) async {
    final supaClient = Supabase.instance.client;
    try {
      final response = await supaClient.from('likes')
        .delete()
        .match({
          'id_usuario' : SupabaseAuthService.id,
          'id_publicacion' : id_publi
      });
    } catch (e) {
      // ERROR AL QUITAR EL LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // SOBRESCRIBO EL HASHCODE PARA DEFINIR CUANDO 2 PUBLICACIONES SON IGUALES
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Publicacion && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
