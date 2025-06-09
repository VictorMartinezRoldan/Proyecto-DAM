import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/components/animacionCreacionUsuario.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/loginRegisterLayout.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterInformationPage extends StatefulWidget {
  final String email;

  const RegisterInformationPage({super.key, required this.email});

  @override
  State<RegisterInformationPage> createState() =>
      _RegisterInformationPageState();
}

class _RegisterInformationPageState extends State<RegisterInformationPage> {
  final controladorNombre = TextEditingController();
  final controladorNombreUsuario = TextEditingController();
  final controladorDescripcion = TextEditingController();
  // Variables de estado para controlar la interfaz
  bool isLoading = false;
  int pasoActual = 0;

  // Variables para cargar las imagenes
  File? imagenPortada;
  File? imagenPerfil;
  List<String> imagenesPortadaPredeterminadas = [];
  List<String> imagenesPerfilPredeterminadas = [];
  bool cargandoImagenesPortada = false;
  bool cargandoImagenesPerfil = false;
  final ImagePicker _picker = ImagePicker();
  int? indicePortadaSeleccionada;
  int? indicePerfilSeleccionada;

  @override
  void initState() {
    super.initState();
    // Cargar las imagenes predeterminadas al iniciar
    _cargarImagenesPredeterminadas();
  }

  // Metodo para cagar las imagenes de portada y perfil desde Supabase
  Future<void> _cargarImagenesPredeterminadas() async {
    await _cargarImagenesPortada();
    await _cargarImagenesPerfil();
  }

  // Metodo para cargar las urls de las imagenes de portada desde el bucket de Supabase
  Future<void> _cargarImagenesPortada() async {
    setState(() => cargandoImagenesPortada = true);
    try {
      final supabase = Supabase.instance.client;
      // Listar los archivos del bucket imagenes
      final files = await supabase.storage
          .from('imagenes')
          .list(path: 'portadas_usuario/predeterminadas');
      imagenesPortadaPredeterminadas =
          files
              .map(
                (file) => supabase.storage
                    .from('imagenes')
                    .getPublicUrl(
                      'portadas_usuario/predeterminadas/${file.name}',
                    ),
              )
              .toList();
    } catch (e) {}
    setState(() => cargandoImagenesPortada = false);
  }

  // Metodo para cargar las urls de las imagenes de perfil desde el bucket de Supabase
  Future<void> _cargarImagenesPerfil() async {
    setState(() => cargandoImagenesPerfil = true);
    try {
      final supabase = Supabase.instance.client;
      // Listar los archivos del bucket imagenes
      final files = await supabase.storage
          .from('imagenes')
          .list(path: 'perfiles_usuario/predeterminadas');
      imagenesPerfilPredeterminadas =
          files
              .map(
                (file) => supabase.storage
                    .from('imagenes')
                    .getPublicUrl(
                      'perfiles_usuario/predeterminadas/${file.name}',
                    ),
              )
              .toList();
    } catch (_) {}
    setState(() => cargandoImagenesPerfil = false);
  }

  // Metodo para poder seleccionar una imagen de la galeria o de la camara
  Future<void> _seleccionarImagen(bool esPortada, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        if (esPortada) {
          imagenPortada = File(picked.path);
        } else {
          imagenPerfil = File(picked.path);
        }
      });
    }
  }

  // Descargar imagen predeterminada y guardarla como archivo temporal (evitamos subir la misma imagen varias veces)
  Future<void> _seleccionarImagenPredeterminada(
    String url,
    bool esPortada,
  ) async {
    try {
      // Crear instancia de httpClient
      final httpClient = HttpClient();
      // Hacer solicitud get
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      // Leer los chunks y almacenar los bytes
      final List<int> bytes = [];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }

      // Crear directorio temporal para evitar duplicados
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(bytes);

      // Actualizar estado del widget
      setState(() {
        if (esPortada) {
          imagenPortada = tempFile;
        } else {
          imagenPerfil = tempFile;
        }
      });
    } catch (_) {
      MensajeSnackbar.mostrarError(context, 'Error al seleccionar la imagen');
    }
  }

  // Widget para la seleccion de imagen
  Widget buildLineaSeleccionImagen({
    required String titulo,
    required File? imagenSeleccionada,
    required int? indiceSeleccionado,
    required Function(int) onSeleccionarPredeterminada,
    required List<String> imagenesPredeterminadas,
    required bool cargando,
    required VoidCallback onTomarOSubir,
  }) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child:
              cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 1 + imagenesPredeterminadas.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Detectar si se elige galeria o camara
                        return GestureDetector(
                          onTap: onTomarOSubir,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              child:
                                  imagenSeleccionada != null
                                      ? ClipOval(
                                        child: Image.file(
                                          imagenSeleccionada,
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.add_a_photo,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                            ),
                          ),
                        );
                      } else {
                        // Imagenes predeterminadas
                        final url = imagenesPredeterminadas[index - 1];
                        final seleccionado = indiceSeleccionado == (index - 1);

                        return GestureDetector(
                          onTap: () => onSeleccionarPredeterminada(index - 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: AnimatedScale(
                              scale: seleccionado ? 1.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      seleccionado
                                          // Borde de color y sombra si la imagen esta seleccionada
                                          ? Border.all(
                                            color: custom.colorEspecial,
                                            width: 4,
                                          )
                                          : null,
                                  boxShadow:
                                      seleccionado
                                          ? [
                                            BoxShadow(
                                              color: custom.colorEspecial
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                          : null,
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: CachedNetworkImageProvider(
                                    url,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
        ),
      ],
    );
  }

  // Metodo para subir la imagen a Supabase y devolver la url
  Future<String> _subirImagen(File imagen, String rutaDestino) async {
    final supabase = Supabase.instance.client;
    final bucket = supabase.storage.from('imagenes');
    await bucket.upload(
      rutaDestino,
      imagen,
      fileOptions: const FileOptions(upsert: true),
    );
    return bucket.getPublicUrl(rutaDestino);
  }
  
  // Metodo para guardar la informacion del usuario en Supabase
  Future<void> _guardarInformacionUsuario() async {
    // Si alguno de los campos esta vacio mostrar error
    if (controladorNombre.text.trim().isEmpty ||
        controladorNombreUsuario.text.trim().isEmpty ||
        controladorDescripcion.text.trim().isEmpty) {
      MensajeSnackbar.mostrarError(
        context,
        'Por favor completa todos los campos',
      );
      return;
    }

    setState(() {
      // Activar el estado de carga
      isLoading = true;
    });

    try {
      // Obtener el usuario actual
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        final Map<String, dynamic> updateData = {
          'nombre': controladorNombre.text.trim(),
          'nombre_usuario': controladorNombreUsuario.text.trim(),
          'descripcion': controladorDescripcion.text.trim(),
          'perfil_completado': true,
        };

        // Imagen de perfil, si es predeterminada se usa la url y si no se sube
        if (indicePerfilSeleccionada != null) {
          updateData['imagen_perfil'] =
              imagenesPerfilPredeterminadas[indicePerfilSeleccionada!];
        } else if (imagenPerfil != null) {
          final urlPerfil = await _subirImagen(
            imagenPerfil!,
            'perfiles_usuario/${user.id}/perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          updateData['imagen_perfil'] = urlPerfil;
        }

        // Imagen de portada, si es predeterminada se usa la url y si no se sube
        if (indicePortadaSeleccionada != null) {
          updateData['imagen_portada'] =
              imagenesPortadaPredeterminadas[indicePortadaSeleccionada!];
        } else if (imagenPortada != null) {
          final urlPortada = await _subirImagen(
            imagenPortada!,
            'portadas_usuario/${user.id}/portada_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          updateData['imagen_portada'] = urlPortada;
        }

        // Actualizar datos en Supabase
        await Supabase.instance.client
            .from('usuarios')
            .update(updateData)
            .eq('id', user.id);

        // Actualizar los datos del usuario localmente
        await SupabaseAuthService().obtenerUsuario();

        // Redirigir a la pantalla principal
        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder:
                (context) => AnimacionCreacionUsuario(
                  imagenPerfilUrl: updateData['imagen_perfil'],
                  nombreUsuario: controladorNombreUsuario.text.trim(),
                  onAnimacionCompleta: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => PagesManager()),
                      (route) => false,
                    );
                  },
                ),
          ),
        );
      }
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al guardar información: ${e.toString()}',
      );
    } finally {
      // Desactivar el estado de carga
      setState(() {
        isLoading = false;
      });
    }
  }

  // Metodo para avanzar los pasos de creacioon del usuario
  Future<void> _siguientePaso() async {
    String? error;

    switch (pasoActual) {
      case 0:
        error = validarNombre(controladorNombre.text);
        break;
      case 1:
        error = validarNombreUsuario(controladorNombreUsuario.text);
        if (error == null) {
          /// Verifica que el nombre de usuario sea único en la base de datos
          final existe = await Supabase.instance.client.from('usuarios')
                  .select('id')
                  .eq('nombre_usuario',controladorNombreUsuario.text.trim().toLowerCase(),)
                  .maybeSingle();

          if (existe != null) {
            error = 'El nombre de usuario ya está en uso';
          }
        }
        break;
      case 2:
        error = validarDescripcion(controladorDescripcion.text);
        break;
      case 3:
      // Debe haber portada y perfil seleccionados (personalizada o predeterminada)
        if ((imagenPortada == null && indicePortadaSeleccionada == null) ||
            (imagenPerfil == null && indicePerfilSeleccionada == null)) {
          error = 'Selecciona una imagen de portada y de perfil';
        }
        break;
    }

    if (error != null) {
      // Quitar el teclado para ver bien los snackbar
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      MensajeSnackbar.mostrarError(context, error);
      return;
    }

    // Avanzar al siguiente paso o finalizar el registro
    if (pasoActual < 3) {
      setState(() {
        pasoActual++;
      });
    } else {
      // Guardar la informacion
      _guardarInformacionUsuario();
    }
  }

  // Metodo para volver al paso anterior
  void _pasoAnterior() {
    if (pasoActual > 0) {
      setState(() {
        pasoActual--;
      });
    }
  }

  // Validacion de nombre
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

  // Validacion de nombre de usuario
  String? validarNombreUsuario(String nombreUsuario) {
    if (nombreUsuario.contains(' ')) {
      return 'El nombre de usuario no puede contener espacios';
    }

    nombreUsuario = nombreUsuario.trim().toLowerCase();

    if (nombreUsuario.isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }

    if (nombreUsuario.length < 5) {
      return 'El nombre de usuario debe tener al menos 5 caracteres';
    }

    if (nombreUsuario.length > 20) {
      return 'El nombre de usuario no puede exceder 20 caracteres';
    }

    // Solo letras, numeros, puntos y guiones bajos
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(nombreUsuario)) {
      return 'Solo se permiten letras, números, puntos y guiones bajos';
    }

    // No puede comenzar o terminar con punto o guion bajo
    if (nombreUsuario.startsWith('.') ||
        nombreUsuario.startsWith('_') ||
        nombreUsuario.endsWith('.') ||
        nombreUsuario.endsWith('_')) {
      return 'No puede comenzar o terminar con punto o guión bajo';
    }

    // No permitir caracteres especiales consecutivos
    if (nombreUsuario.contains('..') ||
        nombreUsuario.contains('__') ||
        nombreUsuario.contains('._') ||
        nombreUsuario.contains('_.')) {
      return 'No se permiten caracteres especiales consecutivos';
    }

    return null;
  }

  // Metodo para validar la descripcion
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

  // Limpiar controladores al destruir el widget
  @override
  void dispose() {
    controladorNombre.dispose();
    controladorNombreUsuario.dispose();
    controladorDescripcion.dispose();
    super.dispose();
  }

  // Metodo con switch para devolver iconos dependiendo del paso actual
  IconData _obtenerIconoActual() {
    switch (pasoActual) {
      case 0:
        return LineAwesomeIcons.signature;
      case 1:
        return Icons.alternate_email_outlined;
      case 2:
        return LineAwesomeIcons.pen;
      case 3:
        return LineAwesomeIcons.retro_camera;
      default:
        return LineAwesomeIcons.question_circle;
    }
  }

  double _obtenerContentHeightFactor() {
    switch (pasoActual) {
      case 0:
        return 0.53; // Menor altura para el paso de nombre
      case 1:
        return 0.55; // Menor altura para el paso de usuario
      case 2:
        return 0.59; // Altura media para la descripción
      case 3:
        return 0.79; // Más altura para la selección de imágenes
      default:
        return 0.58;
    }
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    return LoginRegisterLayout(
      // Icono dinamico
      iconoSuperior: _obtenerIconoActual(),
      // Altura de la pagina
      contentHeightFactor: _obtenerContentHeightFactor(),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de progreso con 3 barras
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ), // Espacio entre barras
                  decoration: BoxDecoration(
                    // Pintar de color el paso actual y el anterior
                    color:
                        pasoActual >= index
                            ? custom.colorEspecial
                            : custom.bordeContenedor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // Paso 0 > añadir el nombre
            if (pasoActual == 0) ...[
              const Text(
                '¿Cuál es tu nombre?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Por favor, introduce tu nombre para personalizar tu experiencia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: custom.bordeContenedor.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 30),
              MyTextField(
                // Usar MyTextField si es el estilo deseado
                hintString: "Tu nombre",
                controller: controladorNombre,
                maxLength: 20,
              ),
            ],
            // Paso 1 > añadir el nombre de usuario
            if (pasoActual == 1) ...[
              const Text(
                'Elige tu nombre de usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Crea un nombre de usuario único que otros\npuedan usar para encontrarte en Petlink y conectar contigo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: custom.bordeContenedor.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 30),
              MyTextField(
                // Usar MyTextField si es el estilo deseado
                hintString: "Nombre de usuario",
                controller: controladorNombreUsuario,
                maxLength: 20,
              ),
            ],
            // Paso 2 > añadir la descripcion
            if (pasoActual == 2) ...[
              const Text(
                'Cuéntanos sobre ti',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Preséntate a la comunidad PetLink. Habla de tus mascotas, tus intereses o qué buscas aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: custom.bordeContenedor.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 30),
              // Textfield para agregar varias lineas
              TextField(
                controller: controladorDescripcion,
                // 4 lineas maximo
                maxLines: 4,
                style: TextStyle(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: custom.bordeContenedor.withValues(alpha: 0.10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      width: 3,
                      color: custom.colorEspecial,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: custom.bordeContenedor.withValues(alpha: 0.10),
                    ),
                  ),
                  hintText: "Descripción",
                  hintStyle: TextStyle(
                    color: custom.bordeContenedor.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
            // Paso 3 > Imágenes de portada y perfil
            if (pasoActual == 3) ...[
              const Text(
                'Personaliza tu perfil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Elige una imagen de portada y una de perfil.\nPuedes tomar una foto, subirla o elegir una predeterminada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: custom.bordeContenedor.withAlpha(120),
                ),
              ),
              const SizedBox(height: 25),
              buildLineaSeleccionImagen(
                titulo: "Imagen de portada",
                imagenSeleccionada: imagenPortada,
                indiceSeleccionado: indicePortadaSeleccionada,
                onSeleccionarPredeterminada: (i) {
                  setState(() {
                    indicePortadaSeleccionada = i;
                    imagenPortada = null;
                  });
                },
                imagenesPredeterminadas: imagenesPortadaPredeterminadas,
                cargando: cargandoImagenesPortada,
                onTomarOSubir: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildModalSeleccionImagen(true),
                  );
                },
              ),
              const SizedBox(height: 30),
              buildLineaSeleccionImagen(
                titulo: "Imagen de perfil",
                imagenSeleccionada: imagenPerfil,
                indiceSeleccionado: indicePerfilSeleccionada,
                onSeleccionarPredeterminada: (i) {
                  setState(() {
                    indicePerfilSeleccionada = i;
                    imagenPerfil = null;
                  });
                },
                imagenesPredeterminadas: imagenesPerfilPredeterminadas,
                cargando: cargandoImagenesPerfil,
                onTomarOSubir: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildModalSeleccionImagen(false),
                  );
                },
              ),
            ],
            const SizedBox(height: 40),
            // Botones para navegar hacia atras o hacia adelante
            Row(
              children: [
                // Mostrar el boton volver si el paso es mayor que 0
                if (pasoActual > 0)
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _pasoAnterior,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: custom.colorEspecial),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Volver',
                          style: TextStyle(
                            color: custom.colorEspecial,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (pasoActual > 0) const SizedBox(width: 15),
                // Botones dinamicos dependiendo del paso en el que se este
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: BlueButton(
                      text:
                          isLoading
                              ? "GUARDANDO..."
                              : pasoActual == 3
                              ? "FINALIZAR"
                              : "CONTINUAR",
                      onPressed: isLoading ? null : _siguientePaso,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Textos informativos
            Text(
              pasoActual == 0
                  ? 'Esto se mostrará en la aplicación\ny se usará para personalizar tu perfil.'
                  : pasoActual == 1
                  ? 'Tu nombre de usuario debe ser único y\npuede cambiarse más tarde en la configuración.'
                  : pasoActual == 2
                  ? 'Escribe una breve descripción sobre ti.\nEsto ayudará a otros usuarios a conocerte mejor.'
                  : '¡Ya casi terminas! Personaliza tu perfil con imágenes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: custom.bordeContenedor.withAlpha(120),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Modal para elegir entre galeria/cámara
  Widget _buildModalSeleccionImagen(bool esPortada) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(esPortada, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(esPortada, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
