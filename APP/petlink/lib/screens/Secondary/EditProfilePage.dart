import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final CustomColors custom =
      Theme.of(
        context,
      ).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late final ColorScheme tema =
      Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  final ImagePicker _seleccion = ImagePicker();
  final supabase = Supabase.instance.client;

  File? _imagenPortada;
  File? _imagenPerfil;
  late final TextEditingController _controladorNombre;
  late final TextEditingController _controladorDescripcion;

  bool _cargando = false;

  // Listas para almacenar imagenes predeterminadas de perfil y portada
  List<String> _imagenesPerfilPredeterminadas = [];
  List<String> _imagenesPortadaPredeterminadas = [];
  bool _cargandoImagenesPerfil = false;
  bool _cargandoImagenesPortada = false;

  @override
  void initState() {
    super.initState();
    _controladorNombre = TextEditingController(
      text: SupabaseAuthService.nombre,
    );
    _controladorDescripcion = TextEditingController(
      text: SupabaseAuthService.descripcion,
    );
    _cargarImagenesPredeterminadas();
  }

  // Validacion nombre
  String? validarNombre(String nombre) {
    String nombreOriginal = nombre;
    String nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return 'El nombre es obligatorio';
    }

    if (nombreLimpio.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (nombreLimpio.length > 20) {
      return 'El nombre no puede exceder 20 caracteres';
    }

    // No permitir espacios multiples
    if (nombreOriginal.contains(RegExp(r'\s{2,}'))) {
      return 'No se permiten espacios múltiples';
    }

    // No permitir espacios al inicio o fin
    if (nombreOriginal != nombreLimpio) {
      return 'El nombre no puede comenzar o terminar con espacios';
    }

    // Solo letras, acentos y espacios
    if (!RegExp(r'^[a-zA-ZÀ-ÿñÑüÜ\s]+$').hasMatch(nombreLimpio)) {
      return 'El nombre solo puede contener letras y espacios';
    }

    return null;
  }

  // Validacion descripcion
  String? validarDescripcion(String descripcion) {
    descripcion = descripcion.trim();

    if (descripcion.isEmpty) {
      return 'La descripción es obligatoria';
    }

    if (descripcion.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }

    if (descripcion.length > 320) {
      return 'La descripción no puede exceder 320 caracteres';
    }

    // Verificar que no sea solo espacios o caracteres especiales
    if (!RegExp(r'.*[a-zA-ZÀ-ÿñÑüÜ0-9].*').hasMatch(descripcion)) {
      return 'La descripción debe contener al menos una letra o número';
    }

    return null;
  }

  // Metodo para cargar imagenes predeterminadas del bucket de Supabase
  Future<void> _cargarImagenesPredeterminadas() async {
    await _cargarImagenesPerfil();
    await _cargarImagenesPortada();
  }

  // Metodo separado para cargar imágenes de perfil
  Future<void> _cargarImagenesPerfil() async {
    setState(() => _cargandoImagenesPerfil = true);

    try {
      final List<FileObject> filesPerfil = await supabase.storage
          .from('imagenes')
          .list(path: 'perfiles_usuario/predeterminadas');

      _imagenesPerfilPredeterminadas =
          filesPerfil
              .map(
                (file) => supabase.storage
                    .from('imagenes')
                    .getPublicUrl(
                      'perfiles_usuario/predeterminadas/${file.name}',
                    ),
              )
              .toList();
    } catch (e) {
      if (!mounted) return;
      MensajeSnackbar.mostrarError(
        context,
        'Error al cargar imágenes de perfil predeterminadas: $e',
      );
    } finally {
      if (mounted) setState(() => _cargandoImagenesPerfil = false);
    }
  }

  // Metodo separado para cargar imágenes de portada
  Future<void> _cargarImagenesPortada() async {
    setState(() => _cargandoImagenesPortada = true);

    try {
      final List<FileObject> filesPortada = await supabase.storage
          .from('imagenes')
          .list(path: 'portadas_usuario/predeterminadas');

      _imagenesPortadaPredeterminadas =
          filesPortada
              .map(
                (file) => supabase.storage
                    .from('imagenes')
                    .getPublicUrl(
                      'portadas_usuario/predeterminadas/${file.name}',
                    ),
              )
              .toList();
    } catch (e) {
      
      if (!mounted) return;
      MensajeSnackbar.mostrarError(context, 'Error al cargar imágenes de portada predeterminadas: $e');
    } finally {
      if (mounted) setState(() => _cargandoImagenesPortada = false);
    }
  }

  // Metodo para mostrar el modal de seleccion de imagenes
  void _mostrarOpcionesImagen(BuildContext context, bool esPortada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              // Altura dinmica para mostrar mas contenido
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Text(
                    esPortada
                        ? AppLocalizations.of(context)!.editProfileFront
                        : AppLocalizations.of(context)!.editProfileProfile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opciones de seleccion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Subir desde la galeria
                      _opcionIcono(
                        icon: LineAwesomeIcons.photo_video,
                        label: AppLocalizations.of(context)!.editProfileGallery,
                        onTap: () {
                          Navigator.pop(context);
                          _seleccionarImagenDesdeGaleria(esPortada);
                        },
                      ),

                      // Subir desde la camara
                      _opcionIcono(
                        icon: LineAwesomeIcons.camera,
                        label: AppLocalizations.of(context)!.editProfileCamera,
                        onTap: () {
                          Navigator.pop(context);
                          _tomarFoto(esPortada);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Imagenes predeterminadas
                  Text(
                    AppLocalizations.of(context)!.editProfileImage,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Contenedor de imagenes predeterminadas
                  Expanded(child: _buildImagenesPredeterminadasGrid(esPortada)),

                  const SizedBox(height: 10),
                  // Botón cancelar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.editProfileCancel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget para mostrar el grid de imágenes predeterminadas
  Widget _buildImagenesPredeterminadasGrid(bool esPortada) {
    final bool estaCargando =
        esPortada ? _cargandoImagenesPortada : _cargandoImagenesPerfil;
    final List<String> imagenes =
        esPortada
            ? _imagenesPortadaPredeterminadas
            : _imagenesPerfilPredeterminadas;

    if (estaCargando) {
      return Center(
        child: CircularProgressIndicator(color: custom.colorEspecial),
      );
    }

    if (imagenes.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.editProfileNotAvailable),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imagenes.length,
      itemBuilder: (context, index) {
        final String imageUrl = imagenes[index];
        return GestureDetector(
          onTap: () {
            _seleccionarImagenPredeterminada(imageUrl, esPortada);
            Navigator.pop(context);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: custom.contenedor,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: custom.colorEspecial,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: custom.contenedor,
                    child: const Icon(
                      LineAwesomeIcons.exclamation_circle,
                      color: Colors.red,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  // Widget para opción con icono
  Widget _opcionIcono({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: custom.colorEspecial),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Método para seleccionar imagen predeterminada
  Future<void> _seleccionarImagenPredeterminada(
    String imageUrl,
    bool esPortada,
  ) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);

      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          if (esPortada) {
            _imagenPortada = tempFile;
          } else {
            _imagenPerfil = tempFile;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        MensajeSnackbar.mostrarError(
          context,
          'Error al seleccionar la imagen: $e',
        );
      }
    }
  }

  // Método para seleccionar imagen desde galería
  Future<void> _seleccionarImagenDesdeGaleria(bool esPortada) async {
    try {
      final imagenSeleccionada = await _seleccion.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (imagenSeleccionada != null && mounted) {
        setState(() {
          if (esPortada) {
            _imagenPortada = File(imagenSeleccionada.path);
          } else {
            _imagenPerfil = File(imagenSeleccionada.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        MensajeSnackbar.mostrarError(
          context,
          'Error al seleccionar la imagen: $e',
        );
      }
    }
  }

  // Método para tomar foto con la cámara
  Future<void> _tomarFoto(bool esPortada) async {
    try {
      final imagenTomada = await _seleccion.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (imagenTomada != null && mounted) {
        setState(() {
          if (esPortada) {
            _imagenPortada = File(imagenTomada.path);
          } else {
            _imagenPerfil = File(imagenTomada.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        MensajeSnackbar.mostrarError(context, 'Error al tomar la foto: $e');
      }
    }
  }

  // Metodo para guardar el perfil
  Future<void> _guardarPerfil() async {
    // Validar nombre
    final errorNombre = validarNombre(_controladorNombre.text);
    if (errorNombre != null) {
      MensajeSnackbar.mostrarError(context, errorNombre);
      return;
    }

    // Validar descripción
    final errorDescripcion = validarDescripcion(_controladorDescripcion.text);
    if (errorDescripcion != null) {
      MensajeSnackbar.mostrarError(context, errorDescripcion);
      return;
    }

    setState(() => _cargando = true);

    try {
      final userId = SupabaseAuthService.id; // ID DEL USUARIO AUTENTICADO

      if (userId == null) {
        throw Exception('ID de usuario no disponible');
      }

      // Preparar datos para actualizar (usar valores limpios)
      final Map<String, dynamic> updateData = {
        'nombre': _controladorNombre.text.trim(),
        'descripcion': _controladorDescripcion.text.trim(),
      };

      // Subir imagenes si existen
      if (_imagenPerfil != null) {
        updateData['imagen_perfil'] = await _subirImagen(
          _imagenPerfil!,
          'perfiles_usuario/$userId/perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (_imagenPortada != null) {
        updateData['imagen_portada'] = await _subirImagen(
          _imagenPortada!,
          'portadas_usuario/$userId/portada_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
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

      if (mounted) {
        setState(() => _cargando = false);
        MensajeSnackbar.mostrarExito(
          context,
          'Perfil actualizado correctamente',
        );
        Navigator.pop(
          context,
          true,
        ); // TRUE PARA INDICAR QUE SE HICIERON CAMBIOS
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        MensajeSnackbar.mostrarError(
          context,
          'Error al guardar el perfil: ${e.toString()}',
        );
      }
    }
  }

  // Metodo para subir la imagen al bucket de Supabase y obtener la URL
  Future<String> _subirImagen(File imagen, String rutaDestino) async {
    // Bucket imagenes
    final bucket = supabase.storage.from('imagenes');

    // Opciones para la subida del archivo
    const opciones = FileOptions(
      cacheControl: '3600', // Tiempo cache
      upsert: false, // Si existe no se sobreescribe
    );

    // Subir la imagen al bucket
    await bucket.upload(rutaDestino, imagen, fileOptions: opciones);

    // Obtener la URL publica
    final urlPublica = bucket.getPublicUrl(rutaDestino);
    return urlPublica;
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorDescripcion.dispose();
    super.dispose();
  }

  // Contenido principal de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfileTitle,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _cargando
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(color: custom.colorEspecial),
                ),
              )
              : TextButton.icon(
                onPressed: _guardarPerfil,
                icon: Icon(LineAwesomeIcons.save, color: custom.colorEspecial),
                label: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(color: custom.colorEspecial, fontSize: 16),
                ),
              ),
        ],
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileImageHeader(),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construirTextos(
                            controller: _controladorNombre,
                            label: AppLocalizations.of(context)!.name,
                            icon: LineAwesomeIcons.user,
                          ),
                          const SizedBox(height: 15),
                          _construirTextos(
                            controller: _controladorDescripcion,
                            label: AppLocalizations.of(context)!.description,
                            icon: LineAwesomeIcons.info_circle,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _cargando ? null : _guardarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: custom.colorEspecial,
                                foregroundColor: custom.contenedor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                        AppLocalizations.of(
                                          context,
                                        )!.saveChanges,
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

  // Widget separado para el encabezado con las imágenes
  Widget _buildProfileImageHeader() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Imagen de portada
        GestureDetector(
          onTap: () => _mostrarOpcionesImagen(context, true),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
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
              child: const Center(
                child: Icon(
                  LineAwesomeIcons.camera,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Imagen de perfil
        Positioned(
          bottom: -50,
          child: GestureDetector(
            onTap: () => _mostrarOpcionesImagen(context, false),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 4),
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
                    child: const Icon(
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
    );
  }

  // Widget para construir los campos de texto
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
          borderSide: BorderSide(color: custom.contenedor, width: 2),
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
