import 'package:flutter/cupertino.dart';
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

  Future<List<String>> obtenerPublicacionesPorUsuario(String userId) async {
    try {
      if (userId.isEmpty) {
        return [];
      }

      final response = await supabase
          .from('publicaciones')
          .select('imagen_url')
          .eq('id_usuario', userId);


      if (response.isNotEmpty) {
        List<String> publicacionesUsuario = response
            .map((post) => post['imagen_url'] as String?)
            .whereType<String>()
            .toList();
        return publicacionesUsuario;
      } else {
        return [];
      }
    } catch (e) {
      return [];
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
