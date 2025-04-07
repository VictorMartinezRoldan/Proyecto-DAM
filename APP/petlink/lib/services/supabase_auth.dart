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

      SupabaseAuthService.isLogin.value = true;
      id = datos["id"];
      imagenPerfil = datos["imagen_perfil"];
      imagenPortada = datos["imagen_portada"];
      nombre = datos["nombre"];
      nombreUsuario = datos["nombre_usuario"];
      descripcion = datos["descripcion"];
      correo = datos["correo"];
      print("ID --> $id");
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

}
