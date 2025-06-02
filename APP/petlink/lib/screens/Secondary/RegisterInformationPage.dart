import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
        // Actualizar con los nuevos campos del usuario  y se completa el perfil para dicho usuario
        await Supabase.instance.client
            .from('usuarios')
            .update({
              'nombre': controladorNombre.text.trim(),
              'nombre_usuario': controladorNombreUsuario.text.trim(),
              'descripcion': controladorDescripcion.text.trim(),
              'perfil_completado': true,
            })
            .eq('id', user.id);

        // Actualizar los datos del usuario localmente
        await SupabaseAuthService().obtenerUsuario();

        // Redirigir a la pantalla principal
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PagesManager()),
          // Limpiar rutas
          (route) => false,
        );
      }
    } catch (e) {
      MensajeSnackbar.mostrarError(
        context,
        'Error al guardar información: ${e.toString()}',
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
    // Validacion para el paso 0 > nombre
    if (pasoActual == 0 && controladorNombre.text.trim().isEmpty) {
      MensajeSnackbar.mostrarError(context, 'Por favor ingresa tu nombre');
      return;
    }
    // Validacion para el paso 1 > nombre de usuario
    if (pasoActual == 1) {
      String username = controladorNombreUsuario.text.trim();
      if (username.isEmpty) {
        MensajeSnackbar.mostrarError(
          context,
          'Por favor ingresa un nombre de usuario',
        );
        return;
      }
      if (username.length <= 5) {
        MensajeSnackbar.mostrarError(
          context,
          'El nombre de usuario debe tener al menos 6 caracteres',
        );
        return;
      }
      // Verificar si el nuevo nombre de usuario ya existe
      final existe =
          await Supabase.instance.client
              .from('usuarios')
              .select('id')
              .eq('nombre_usuario', username)
              .maybeSingle();

      if (existe != null) {
        MensajeSnackbar.mostrarError(
          context,
          'El nombre de usuario ya está en uso',
        );
        return;
      }
    }
    // Validacion para el paso 2 > descripcion del usuario
    if (pasoActual == 2 && controladorDescripcion.text.trim().isEmpty) {
      MensajeSnackbar.mostrarError(
        context,
        'Por favor ingresa una descripción',
      );
      return;
    }

    // Avanzar al siguiente paso o finalizar el registro
    if (pasoActual < 2) {
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
      default:
        return LineAwesomeIcons.question_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    return LoginRegisterLayout(
      // Icono dinamico
      iconoSuperior: _obtenerIconoActual(),
      // Altura de la pagina
      contentHeightFactor: 0.60,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de progreso con 3 barras
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
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
                'Por favor, introduce tu nombre completo para personalizar tu experiencia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: custom.bordeContenedor.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 30),
              MyTextField(
                // Usar MyTextField si es el estilo deseado
                hintString: "Tu nombre completo",
                controller: controladorNombre,
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
              ),
              // Paso 2 > añadir la descripcion
            ] else if (pasoActual == 2) ...[
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
                style: TextStyle(
                ),
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
                              : pasoActual == 2
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
                  : 'Escribe una breve descripción sobre ti.\nEsto ayudará a otros usuarios a conocerte mejor.', // Texto para pasoActual == 2
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: custom.bordeContenedor.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
