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
        return null;
      }

      print("✅ Usuario autenticado: ${user.email} - ID: ${user.id}");

      final datos =
          await supabase
              .from('usuarios')
              .select(
                'id, nombre_usuario, nombre, descripcion, imagen_perfil, imagen_portada, correo',
              ) // 🔹 Asegurar que 'id' está presente
              .eq('id', user.id)
              .maybeSingle();

      if (datos == null) {
        print("⚠️ No se encontraron datos para el usuario con ID: ${user.id}");
        return null;
      }

      print("📌 Datos obtenidos: $datos");

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
      print("ID --> $id");

      await obtenerPublicaciones();

    } catch (error) {
      return null;
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
        print("⛔ ID de usuario no disponible");
        return;
      }

      final response = await supabase
          .from('publicaciones')
          .select('imagen_url')
          .eq('id_usuario', id);

      print("📡 Respuesta de publicaciones: $response");

      if (response.isNotEmpty) {
        publicaciones = response
            .map((post) => post['imagen_url'] as String?)
            .whereType<String>()
            .toList();
        print("✅ Publicaciones cargadas: ${publicaciones.length}");
      } else {
        publicaciones = [];
        print("⚠️ No hay publicaciones para este usuario.");
      }
    } catch (e) {
      publicaciones = [];
      print("❌ Error obteniendo publicaciones: $e");
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
      print('Error al verificar perfil: $e');
    }
    return false;
  }

}
