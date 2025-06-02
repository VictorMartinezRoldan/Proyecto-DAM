import 'package:flutter/material.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/botonRedesSociales.dart';
import 'package:petlink/components/loginRegisterLayout.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/components/myTextFieldPassword.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/screens/Secondary/OtpVerificationPage.dart';
import 'package:petlink/screens/Secondary/RegisterInformationPage.dart';
import 'package:petlink/screens/Secondary/RegisterPage.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controladorEmail = TextEditingController();
  final controladorPassword = TextEditingController();
  bool isLoading = false;

  // Metodo para manejar el proceso de inicio de sesion
  Future<void> _login(
    BuildContext context,
    String email,
    String password,

  ) async {
    // Activar el estado de carga
    setState(() => isLoading = true);
    try {
      // Inicio de autenticacion contra Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Comprobar si el usuario tiene el perfil completado
        final perfilCompletado = await SupabaseAuthService().esPerfilCompletado();

        // Si no está completado llevar a la pagina para rellenar la informacion
        if (!perfilCompletado) {
          Navigator.pushReplacement(context,
            MaterialPageRoute(
              builder: (context) => RegisterInformationPage(email: email),
            ),
          );
        } else {

          // Si el usuario esta completo obtener los datos del usuario y redirigir a l pagina principal
          await SupabaseAuthService().obtenerUsuario();

          MensajeSnackbar.mostrarExito(context, 'Logueado correctamente.');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PagesManager()),
          );
        }
      }
    } on AuthException catch (e) {

      // Errores de autenticacion
      if (e.message.contains('Email not confirmed')) {
        await _reenviarConfirmacionOTP(context, email);
      } else {
        MensajeSnackbar.mostrarError(context, 'Error de autenticación: ${e.message}',
        );
      }
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error inesperado: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Funcion para reenviar el codigo OTP si no lo completo al registrarse
  Future<void> _reenviarConfirmacionOTP(
    BuildContext context,
    String email,
  ) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      MensajeSnackbar.mostrarInfo(context, 'Código de confirmación reenviado. Revisa tu correo electrónico.',
      );

      Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(email: email),
        ),
      );
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al reenviar código: $e');
    }
  }

  // Limpiar controladores al destruir el widget
  @override
  void dispose() {
    controladorEmail.dispose();
    controladorPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    // Devolver layout reutilizable y añadir contenido propio de cada pantalla
    return LoginRegisterLayout(
      // Icono circulo
      iconoSuperior: Icons.person_outline,
      // Altura de la pagina
      contentHeightFactor: 0.70,
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
              'Bienvenido de nuevo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Por favor, introduce tus credenciales\npara continuar.',
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: BlueButton(
                // Si no ha pulsado mostrar INICIAR SESION, y si ha pulsado mostrar INICIANDO
                text: isLoading ? "INICIANDO..." : "INICIAR SESIÓN",
                onPressed:
                    isLoading
                    // Deshabilitar el boton mientras esta iniciando
                        ? null
                        : () => _login(
                          context,
                          controladorEmail.text,
                          controladorPassword.text,
                        ),
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
            const SizedBox(height: 25),
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
            const SizedBox(height: 30),
            // Enlace para ir hacia el registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "¿No tienes una cuenta? ",
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
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Regístrate aquí!',
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
