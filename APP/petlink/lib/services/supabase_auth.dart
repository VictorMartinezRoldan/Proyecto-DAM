import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

Future<Map<String, dynamic>?> obtenerUsuario() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("⛔ No hay un usuario autenticado.");
      return null;
    }

    print("✅ Usuario autenticado: ${user.email} - ID: ${user.id}");

    final datos = await supabase
        .from('usuarios')
        .select('id, nombre_usuario, nombre, descripcion, imagen_perfil, imagen_portada') // 🔹 Asegurar que 'id' está presente
        .eq('id', user.id)
        .maybeSingle();

    if (datos == null) {
      print("⚠️ No se encontraron datos para el usuario con ID: ${user.id}");
      return null;
    }

    print("📌 Datos obtenidos: $datos");
    return datos as Map<String, dynamic>;
  } catch (error) {
    print("🔥 Error al obtener datos del usuario: $error");
    return null;
  }
}

  Future<bool> actualizarUsuario(Map<String, dynamic> nuevosDatos) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No hay un usuario autenticado.");
        return false;
      }

      final response = await supabase
          .from('usuarios')
          .update(nuevosDatos)
          .eq('id', user.id);

      if (response.error != null) {
        print("🔥 Error al actualizar datos: ${response.error!.message}");
        return false;
      }

      print("✅ Datos actualizados correctamente.");
      return true;
    } catch (error) {
      print("🔥 Error al actualizar datos del usuario: $error");
      return false;
    }
  }
}
