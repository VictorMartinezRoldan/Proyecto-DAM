// BIBLIOTECAS
import 'package:flutter/material.dart';
import 'package:petlink/components/comentarioStyle.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// CLASES
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/services/supabase_auth.dart';

class Comentario {
  // Atributos de los comentarios
  final int idComentario;
  final int? idRespuesta;
  final String uuid;
  final String imagenPerfil;
  final String nombre;
  final String usuario;
  final String texto;
  final String fecha;
  int likes;
  int numRespuestas;
  bool liked = false;
  final String? usuarioRespondido;
  bool esNuevo;
  int indiceRespuestas = 0;
  List<ComentarioStyle> respuestas = [];

  // Constructor de los comentarios
  Comentario({
    required this.idComentario,
    this.idRespuesta,
    required this.uuid,
    required this.imagenPerfil,
    required this.nombre,
    required this.usuario,
    required this.texto,
    required this.fecha,
    required this.likes,
    required this.numRespuestas,
    required this.liked,
    this.esNuevo = false,
    this.usuarioRespondido
  });

  // Métodos de los comentarios
  

  // Método para solicitar comentarios
  static Future<dynamic> solicitarComentarios(BuildContext context, int idPublicacion, int indice, int numeroComentarios) async {
    try {
      final supaClient = Supabase.instance.client;
      final response = await supaClient.rpc(
        'obtener_comentarios', // LLAMAMOS A UNA FUNCIÓN DENTRO DE LA BD CON UNA CONSULTA AVANZADA
        params: {
          'publicacion': idPublicacion,
          'limit_count': numeroComentarios,
          'indice' : indice,
          'usuario_uid' : (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.id : null
        }
      );
      return response;
    } catch (e) {
      // SE A PRODUCIDO UN ERROR, PRIMERO COMPROBAMOS DE QUE HAYA CONEXIÓN
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected){
        if (!context.mounted) return;
        // Si no tiene conexión a internet...
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return;
    }
  }

  // Metodo para guardar Likes de los comentarios en la BD
  static Future<void> darLikeComentario(BuildContext context, int idComentario) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('likes_comentarios')
        .insert({
          'id_comentario' : idComentario,
          'id_usuario' : SupabaseAuthService.id
      });
    } catch (e) {
      // ERROR AL DAR LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // Metodo para borrar Likes de los comentarios en la BD
  static Future<void> quitarLikeComentario(BuildContext context, int idComentario) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('likes_comentarios')
        .delete()
        .match({
          'id_comentario' : idComentario,
          'id_usuario' : SupabaseAuthService.id
      });
    } catch (e) {
      // ERROR AL QUITAR EL LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // Método para comentar dentro de la BD
  static Future<bool> comentar(BuildContext context, int idComentario, int idPublicacion, String texto) async {
    final supabase = Supabase.instance.client;
    try {
      // SUBO LA PUBLICACIÓN
      await supabase.from("comentarios")
        .insert({
          'id_comentario' : idComentario,
          'id_publicacion' : idPublicacion,
          'id_usuario' : SupabaseAuthService.id,
          'texto' : texto
        });
      return true;
    } catch (e) {
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return false;
    }
  }

  // Metodo para borrar comentarios de la BD
  static Future<void> eliminarComentario(BuildContext context, int idComentario) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('comentarios')
        .delete()
        .match({
          'id_comentario' : idComentario,
      });
    } catch (e) {
      // ERROR AL QUITAR EL LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }
  // ////////////////////////////////////////////////////////////////////////////////////////////
  // ////////////////////////////////////////////////////////////////////////////////////////////
  // ////////////////////////////////////////////////////////////////////////////////////////////

  //                                       ESPUESTAS

  // ////////////////////////////////////////////////////////////////////////////////////////////
  // ////////////////////////////////////////////////////////////////////////////////////////////
  // ////////////////////////////////////////////////////////////////////////////////////////////


  // Método para obtener respuestas de la BD de un comentario.
  static Future<List<Comentario>> solicitarRespuestas(BuildContext context, int idComentario, int indice, int numeroRespuestas) async {
    List<Comentario> respuestas = []; // LISTA DE RESPUESTAS A ENVIAR
    try {
      final supaClient = Supabase.instance.client;
      final response = await supaClient.rpc(
        'obtener_respuestas', // LLAMAMOS A UNA FUNCIÓN DENTRO DE LA BD CON UNA CONSULTA AVANZADA
        params: {
          'comentario': idComentario,
          'limit_count': numeroRespuestas,
          'indice' : indice,
          'usuario_uid' : (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.id : null
        }
      );
      if (response == null || response.isEmpty) {
        return respuestas; // DEVUELVE LAS RESPUESTAS VACÍAS
      } else {
        // SI HAY DATOS, BUCLE POR CADA PUBLICACIÓN RECIBIDA
        for (int i = 0; i < response.length; i++) {
          var datos = response[i]; // EXTRAIGO LA INFORMACIÓN
          // CREO EL OBJETO
           Comentario respuesta = Comentario(
            idComentario: datos["id_comentario"],
            idRespuesta: datos["id_respuesta"],
            uuid: datos["uuid"],
            imagenPerfil: datos["imagen_perfil"], 
            nombre: datos["nombre"],
            usuario: datos["usuario"],
            texto: datos["texto"],
            fecha: datos["fecha_respuesta"],
            numRespuestas: 0, // 0 SIEMPRE
            likes: datos["likes"], 
            liked: datos["liked"],
            usuarioRespondido: datos["usuario_respondido"]
          );
          respuestas.add(respuesta);
        }
        return respuestas; // Devuelvo las respuestas
      }
    } catch (e) {
      // SE A PRODUCIDO UN ERROR, PRIMERO COMPROBAMOS DE QUE HAYA CONEXIÓN
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected){
        if (!context.mounted) return respuestas;
        // Si no tiene conexión a internet...
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return respuestas;
    }
  }

  // Método para responder a otro comentario / respuesta
  static Future<bool> responder(BuildContext context, int idRespuesta, int idComentario, String texto, String uuidUsuarioRespondido) async {
    final supabase = Supabase.instance.client;
    try {
      // SUBO LA RESPUESTA
      await supabase.from("respuestas")
        .insert({
          'id_respuesta' : idRespuesta,
          'id_comentario' : idComentario,
          'id_usuario' : SupabaseAuthService.id,
          'texto' : texto,
          'usuario_respondido' : uuidUsuarioRespondido
        });
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      MensajeSnackbar.mostrarError(context, "No se a podido responder, el comentario a sido eliminado.");
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return false;
    }
  }

  // Metodo para dar like a una respuesta dentro de la BD
  static Future<void> darLikeRespuesta(BuildContext context, int idRespuesta) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('likes_respuestas')
        .insert({
          'id_usuario' : SupabaseAuthService.id,
          'id_respuesta' : idRespuesta
      });
    } catch (e) {
      // ERROR AL DAR LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // Metodo para borrar Likes de una respuesta dentro de la BD
  static Future<void> quitarLikeRespuesta(BuildContext context, int idRespuesta) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('likes_respuestas')
        .delete()
        .match({
          'id_usuario' : SupabaseAuthService.id,
          'id_respuesta' : idRespuesta
      });
    } catch (e) {
      // ERROR AL QUITAR EL LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // Metodo para eliminar una respuesta de la BD
  static Future<void> eliminarRespuesta(BuildContext context, int idRespuesta) async {
    final supaClient = Supabase.instance.client;
    try {
      await supaClient.from('respuestas')
        .delete()
        .match({
          'id_respuesta' : idRespuesta,
      });
    } catch (e) {
      // ERROR AL QUITAR EL LIKE
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    }
  }

  // SOBRESCRIBO EL HASHCODE PARA DEFINIR CUANDO 2 COMENTARIOS SON IGUALES
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comentario && idComentario == other.idComentario;

  @override
  int get hashCode => idComentario.hashCode;
}