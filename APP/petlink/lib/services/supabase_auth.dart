import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petlink/components/comentarioStyle.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/PetSocialPage.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final supabase = Supabase.instance.client;
  static ValueNotifier<bool> isLogin = ValueNotifier<bool>(false);
  static String imagenPerfil = "";
  static String imagenPortada = "";
  static String id = "";
  static String nombre = "";
  static String nombreUsuario = "";
  static String correo = "";
  static String descripcion = "";
  static List<String> publicaciones = [];

  Future<void> obtenerUsuario() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        SupabaseAuthService.isLogin.value = false;
        return;
      }

      // ✅ Usuario autenticado: ${user.email} - ID: ${user.id}

      final datos =
          await supabase
              .from('usuarios')
              .select(
                'id, nombre_usuario, nombre, descripcion, imagen_perfil, imagen_portada, correo',
              ) // 🔹 Asegurar que 'id' está presente
              .eq('id', user.id)
              .maybeSingle();

      if (datos == null) {
        // ⚠️ No se encontraron datos para el usuario con ID: ${user.id}
        return;
      }

      // 📌 Datos obtenidos: $datos

      // DATOS OBTENIDOS
      datos as Map<String, dynamic>;
      id = datos["id"];
      imagenPerfil = datos["imagen_perfil"];
      imagenPortada = datos["imagen_portada"];
      nombre = datos["nombre"];
      nombreUsuario = datos["nombre_usuario"];
      descripcion = datos["descripcion"];
      correo = datos["correo"];
      SupabaseAuthService.isLogin.value = true;

      await obtenerPublicaciones();

    } catch (error) {
      return;
    }
  }

  Future<bool> actualizarUsuario(Map<String, dynamic> nuevosDatos) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await supabase
          .from('usuarios')
          .update(nuevosDatos)
          .eq('id', user.id);

      if (response.error != null) {
        return false;
      }

      return true;
    } catch (error) {
      return false;
    }
  }

    Future<void> obtenerPublicaciones() async {

     try {
      if (id.isEmpty) {
        return;
      }

      final response = await supabase
          .from('publicaciones')
          .select('imagen_url')
          .eq('id_usuario', id);

      if (response.isNotEmpty) {
        publicaciones = response
            .map((post) => post['imagen_url'] as String?)
            .whereType<String>()
            .toList();
      } else {
        publicaciones = [];
      }
    } catch (e) {
      publicaciones = [];
    }
  }

  Future<bool> esPerfilCompletado() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('usuarios')
            .select('perfil_completado')
            .eq('id', user.id)
            .single();
        
        return response['perfil_completado'] ?? false;
      }
    } catch (e) {

    }
    return false;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(String userId) async {
    try {
      final datos = await supabase
          .from('usuarios')
          .select(
            'id, nombre_usuario, nombre, descripcion, imagen_perfil, imagen_portada, correo',
          )
          .eq('id', userId)
          .maybeSingle();

      if (datos == null) {
        return null;
      }
      return datos as Map<String, dynamic>;

    } catch (error) {
      return null;
    }
  }

  Future<List<Publicacion>> obtenerPublicacionesPorUsuario(BuildContext context, String uuid) async {
    List<Publicacion> publicaciones = []; // LISTA DE PUBLICACIONES A ENVIAR
    try {
      if (uuid.isEmpty) {
        return publicaciones; // VACIO
      }


      // CONSULTA A LA BD
      final response = await supabase.rpc(
        'obtener_publicaciones_usuario', // LLAMAMOS A UNA FUNCIÓN DENTRO DE LA BD CON UNA CONSULTA AVANZADA
        params: {
          'usuario_uid' : (uuid)
        }
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
              uuidPubli: datos["uuid"],
              imagenPerfil: datos["imagen_perfil"],
              nombre: datos["nombre"],
              usuario: datos["usuario"],
              texto: datos["texto"],
              fecha: datos["fecha_publicacion"],
              urlImagen: datos["imagen_url"],
              likes: datos["likes"],
              liked: datos["liked"],
              numComentarios: datos["num_comentarios"]
          );

          // --------------------------------------------------------------------------
          // LOGICA PARA REVISAR SI YA EXISTE EN LA LISTA DE PUBLICACIONES
          PublicacionStyle? oldPubliStyle;
          try {
            oldPubliStyle = PetSocialPageState.publicaciones.firstWhere(
              (lista) => lista.publicacion.id == newPubli.id,
            );
            // COMPROBACIÓN NO NECESARIA, PERO POR ASEGURAR QUE NO FALTE
            if (oldPubliStyle != null) {
              newPubli = oldPubliStyle.publicacion; // ASIGNAMOS LA PUBLICACIÓN EXISTENTE
            }
          } catch (_) {
            oldPubliStyle = null;
          }
          // --------------------------------------------------------------------------
          // NO ES USERPAGE
          publicaciones.add(newPubli); // AÑADO A LA LISTA DE PUBLICACIONES A ENVIAR
        }
        return publicaciones;
      }
    } catch (e) {
      // SE A PRODUCIDO UN ERROR, PRIMERO COMPROBAMOS DE QUE HAYA CONEXIÓN
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected){
        if (!context.mounted) return publicaciones;
        // Si no tiene conexión a internet...
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
      return publicaciones;
    }
  }

  Future<bool> eliminarPublicacionesSeleccionadas(List<String> imagenesUrl) async {
    try {
      if (imagenesUrl.isEmpty) {
        return false;
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      await supabase
          .from('publicaciones')
          .delete()
          .eq('id_usuario', user.id)
          .inFilter('imagen_url', imagenesUrl);
      
      await obtenerPublicaciones();
      
      return true;

    } catch (error) {
      // ❌ Error eliminando publicaciones: $error
      return false;
    }
  }
}
