// BIBLIOTECAS
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// CLASES
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/services/supabase_auth.dart';

class Comentario {
  // Atributos de los comentarios
  final int idComentario;
  final String imagenPerfil;
  final String nombre;
  final String usuario;
  final String texto;
  final String fecha;
  int likes;
  int numRespuestas;
  bool liked = false;
  bool esNuevo;

  // Constructor de los comentarios
  Comentario({
    required this.idComentario,
    required this.imagenPerfil,
    required this.nombre,
    required this.usuario,
    required this.texto,
    required this.fecha,
    required this.likes,
    required this.numRespuestas,
    required this.liked,
    this.esNuevo = false
  });

  List<Comentario> respuestas = [];

  // Métodos de los comentarios
  
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

  // Metodo para guardar Likes en la BD
  static Future<void> darLike(BuildContext context, int idComentario) async {
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

  // Metodo para borrar Likes en la BD
  static Future<void> quitarLike(BuildContext context, int idComentario) async {
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
      print('❌ Error al subir comentario: $e');
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

  // Metodo para borrar Likes en la BD
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

  // SOBRESCRIBO EL HASHCODE PARA DEFINIR CUANDO 2 COMENTARIOS SON IGUALES
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comentario && idComentario == other.idComentario;

  @override
  int get hashCode => idComentario.hashCode;
}