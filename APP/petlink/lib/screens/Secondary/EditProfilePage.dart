import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();

  File? _imagenPortada;
  File? _imagenPerfil;
  late TextEditingController _controladorNombre;
  late TextEditingController _controladorDescripcion;

  final ImagePicker _seleccion = ImagePicker();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _controladorNombre = TextEditingController();
    _controladorDescripcion = TextEditingController();
  }

  Future<void> _seleccionarImagen(bool esPortada) async {
    try {
      final imagenSeleccionada = await _seleccion.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (imagenSeleccionada != null) {
        setState(() {
          if (esPortada) {
            _imagenPortada = File(imagenSeleccionada.path);
          } else {
            _imagenPerfil = File(imagenSeleccionada.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al seleccionar la imagen')));
    }
  }

  Future<void> _guardarPerfil() async {
    if (_controladorNombre.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('El nombre no puede estar vacío')));
      return;
    }

    setState(() {
      _cargando = true;
    });

    final messenger = ScaffoldMessenger.of(
      context,
    ); // VARIABLE ANTES DEL AWAIT PARA QUE NO DE PROBLEMAS DE CONTEXTO

    try {
      final supabase = Supabase.instance.client;
      final userId = SupabaseAuthService.id; // ID DEL USUARIO AUTENTICADO

      if (userId == null) {
        throw Exception('ID de usuario no disponible');
      }

      // Preparar datos para actualizar
      Map<String, dynamic> updateData = {
        'nombre': _controladorNombre.text,
        'descripcion': _controladorDescripcion.text,
      };

      // SUBIR IMAGEN DE PERFIL ACTUALIZADA
      // SE SUBEN AL BUCKET PERFILES_USUARIO CON UNA CARPETA PARA CADA USUARIO
      if (_imagenPerfil != null) {
        final imagenPerfilPath =
            'perfiles_usuario/$userId/perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('imagenes')
            .upload(
              imagenPerfilPath,
              _imagenPerfil!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final imagenPerfilUrl = supabase.storage
            .from('imagenes')
            .getPublicUrl(imagenPerfilPath);
        updateData['imagen_perfil'] = imagenPerfilUrl;
      }

      // SUBIR IMAGEN DE PORTADA ACTUALIZADA
      // SE SUBEN AL BUCKET PORTADAS_USUARIO CON UNA CARPETA PARA CADA USUARIO
      if (_imagenPortada != null) {
        final imagenPortadaPath =
            'portadas_usuario/$userId/portada_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('imagenes')
            .upload(
              imagenPortadaPath,
              _imagenPortada!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final imagenPortadaUrl = supabase.storage
            .from('imagenes')
            .getPublicUrl(imagenPortadaPath);
        updateData['imagen_portada'] = imagenPortadaUrl;
      }

      // ACTUALIZAR LOS DATOS EN LA BD
      final response =
          await supabase
              .from('usuarios')
              .update(updateData)
              .eq('id', userId)
              .select();

      if (response.isEmpty) {
        throw Exception('Error al actualizar los datos del usuario');
      }

      // ACTUALIZAR LOS DATOS EN SUPABASEAUTH
      await authService.obtenerUsuario();

      setState(() {
        _cargando = false;
      });

      messenger.showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente')),
      );

      Navigator.pop(context, true); // TRUE PARA INDICAR QUE SE HICIERON CAMBIOS
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Error al guardar el perfil: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    custom = Theme.of(context).extension<CustomColors>()!;
    tema = Theme.of(context).colorScheme;

    _controladorNombre.text = SupabaseAuthService.nombre;
    _controladorDescripcion.text = SupabaseAuthService.descripcion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _cargando
              ? Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(color: custom.colorEspecial),
                ),
              )
              : TextButton.icon(
                onPressed: _guardarPerfil,
                icon: Icon(LineAwesomeIcons.save, color: custom.colorEspecial),
                label: Text(
                  "Guardar",
                  style: TextStyle(color: custom.colorEspecial, fontSize: 16),
                ),
              ),
        ],
      ),
      body:
          _cargando
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => _seleccionarImagen(true),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: tema.surface,
                              image:
                                  _imagenPortada != null
                                      ? DecorationImage(
                                        image: FileImage(_imagenPortada!),
                                        fit: BoxFit.cover,
                                      )
                                      : DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          (SupabaseAuthService.isLogin.value)
                                              ? SupabaseAuthService.imagenPortada
                                              : 'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              child: Center(
                                child: Icon(
                                  LineAwesomeIcons.camera,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          child: GestureDetector(
                            onTap: () => _seleccionarImagen(false),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tema.surface,
                                  width: 4,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: custom.contenedor,
                                    backgroundImage:
                                        _imagenPerfil != null
                                            ? FileImage(_imagenPerfil!)
                                            : CachedNetworkImageProvider(
                                              SupabaseAuthService.imagenPerfil,
                                                )
                                                as ImageProvider,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                    child: Icon(
                                      LineAwesomeIcons.camera,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirTextos(
                            controller: _controladorNombre,
                            label: 'Nombre',
                            icon: LineAwesomeIcons.user,
                          ),
                          SizedBox(height: 15),
                          _construirTextos(
                            controller: _controladorDescripcion,
                            label: 'Descripción',
                            icon: LineAwesomeIcons.info_circle,
                            maxLines: 3,
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _cargando ? null : _guardarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: custom.colorEspecial,
                                foregroundColor: custom.contenedor,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _cargando
                                      ? CircularProgressIndicator(
                                        color: custom.contenedor,
                                      )
                                      : Text(
                                        'Guardar Cambios',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _construirTextos({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: custom.colorEspecial),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tema.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: custom.colorEspecial, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 0,
        ),
      ),
    );
  }
}
