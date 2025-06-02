import 'package:flutter/material.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/botonRedesSociales.dart';
import 'package:petlink/components/indicadorFuerzaPassword.dart';
import 'package:petlink/components/loginRegisterLayout.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/components/myTextFieldPassword.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/screens/Secondary/OtpVerificationPage.dart';
import 'package:petlink/components/providerIdioma.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final controladorEmail = TextEditingController();
  final controladorPassword = TextEditingController();
  
  // Checkbox terminos y condiciones
  bool aceptarTerminos = false;

  Future<void> _register(
    BuildContext context,
    String email,
    String password,

  ) async {
    try {
      // Obtener el idioma para enviar el correo electronico en un idioma u otro
      final idioma = Provider.of<Provideridioma>(context,listen: false).locale.languageCode;

      // Registrar el usuario en supabase con email y contraseña
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'idiomaPreferido': idioma},
      );

      // Si se registra correctamente llevar a la pagina de verificacion de la cuenta
      if (response.user != null) {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: email),
          ),
        );
      }
    } on AuthException catch (e) {
      // Errores de autenticacion
      MensajeSnackbar.mostrarError(context, 'Error de autenticación: ${e.message}');

    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error inesperado: ${e.toString()}');

    }
  }

  // Metodo para validar la contraseña y que cumpla diferentes requisitos
  bool validarPassword(String password, BuildContext context) {
    if (password.length < 6) {
      MensajeSnackbar.mostrarError(context, 'La contraseña debe tener al menos 6 caracteres');

      return false;
    }
    final tieneMayuscula = password.contains(RegExp(r'[A-Z]'));
    final tieneMinuscula = password.contains(RegExp(r'[a-z]'));
    final tieneNumero = password.contains(RegExp(r'[0-9]'));
    final tieneSimbolo = password.contains(RegExp(r'[!@#$%^&*]'));

    // Contar cuantos criterios se cumplen
    final criteriosCumplidos =
        [
          tieneMayuscula,
          tieneMinuscula,
          tieneNumero,
          tieneSimbolo,
        ].where((cumple) => cumple).length;

    // Requiere cumplir 3 de estos 4 parametros
    if (criteriosCumplidos < 3) {
      MensajeSnackbar.mostrarError(
        context,
        'La contraseña debe incluir al menos 3 de estas 4 categorías:\n'
        '- Una letra mayúscula\n'
        '- Una letra minúscula\n'
        '- Un número\n'
        '- Un símbolo (!@#\$%^&*)',
      );

      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Listener para detectar cambios en la contraseña
    controladorPassword.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    // Actualizar la interfaz para mostrar el indicador de fuerza
    setState(() {});
  }

  // Limpiar controladores al destruir el widget
  @override
  void dispose() {
    controladorPassword.removeListener(_onPasswordChanged);
    controladorEmail.dispose(); // Asegúrate de desechar también controladorEmail
    controladorPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    // Devolver layout reutilizable y añadir contenido propio de cada pantalla
    return LoginRegisterLayout(
      // Icono circulo
      iconoSuperior: Icons.person_add_alt_1_outlined,
      // Altura de la pagina
      contentHeightFactor: 0.75,
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: BackButton(
        color: custom.bordeContenedor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PagesManager()),
          );
        },
      ),
    ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '¡Bienvenido! Por favor, introduce tu información\na continuación para comenzar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: custom.bordeContenedor.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 25),
            // TextField personalizados reutilizables
            MyTextField(
              hintString: "Tu correo electrónico",
              controller: controladorEmail,
            ),
            const SizedBox(height: 14),
            MyTextFieldPassword(controller: controladorPassword),
            
            // Implementar el componente indicador de fuerza
            IndicadorFuerzaPassword(password: controladorPassword.text),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: aceptarTerminos,
                  onChanged: (value) {
                    setState(() {
                      aceptarTerminos = value ?? false;
                    });
                  },
                  activeColor: custom.colorEspecial,
                ),
                Expanded(
                  // Para evitar overflow si el texto es largo
                  child: Text(
                    'Aceptar Términos y Condiciones',
                    style: TextStyle(
                      fontSize: 14,
                      color: custom.bordeContenedor.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: BlueButton(
                text: "CREAR CUENTA",
                onPressed: () {
                  // Primero verificar si se aceptaron los terminos
                  if (!aceptarTerminos) {
                    MensajeSnackbar.mostrarInfo(context,  'Debes aceptar los Términos y Condiciones para continuar');
                    return;
                  }
                  
                  // Si estan aceptados, validar la contraseña y registrar
                  if (validarPassword(controladorPassword.text, context)) {
                    _register(
                      context,
                      controladorEmail.text,
                      controladorPassword.text,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 25),
            // Divisor -O-
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: custom.bordeContenedor.withValues(alpha: 0.10),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'O',
                    style: TextStyle(
                      color: custom.bordeContenedor.withValues(alpha: 0.45),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: custom.bordeContenedor.withValues(alpha: 0.10),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Botones de redes sociales reutilizables
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BotonRedesSociales(
                  icon: Brand(Brands.google, size: 32),
                  onTap: () => {},
                ),
                const SizedBox(width: 24),
                BotonRedesSociales(
                  icon: FaIcon(
                    FontAwesomeIcons.apple,
                    size: 32,
                    color: custom.bordeContenedor,
                  ),
                  onTap: () => {},
                ),
                const SizedBox(width: 24),
                BotonRedesSociales(
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    size: 32,
                    color: Color(0xFF1877F2),
                  ),
                  onTap: () => {},
                ),
                const SizedBox(width: 24),
                BotonRedesSociales(
                  icon: FaIcon(
                    FontAwesomeIcons.xTwitter,
                    size: 32,
                    color: custom.bordeContenedor.withValues(alpha: 0.85),
                  ),
                  onTap: () => {},
                ),
              ],
            ),
            const SizedBox(height: 25),
            // Enlace para ir hacia el login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes una cuenta? ',
                  style: TextStyle(
                    fontSize: 15,
                    color: custom.bordeContenedor.withValues(alpha: 0.45),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Inicia sesión aquí!',
                    style: TextStyle(
                      color: custom.colorEspecial,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
