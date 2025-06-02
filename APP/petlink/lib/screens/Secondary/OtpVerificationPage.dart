import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/components/loginRegisterLayout.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/screens/Secondary/RegisterInformationPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/themes/customColors.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;
  
  const OtpVerificationPage({required this.email, Key? key}) : super(key: key);

  // Metodo para verificar el codigo OTP con Supabase
  Future<void> verificarOtp(BuildContext context, String email, String otp) async {
    try {
      // Verificar el codigo con Supabase
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otp,
      );
      if (response.session != null) {
        // Si esta verificado mostrar mensaje de exito y llevar a la siguiente pagina
        MensajeSnackbar.mostrarExito(context, '¡Cuenta confirmada!');

        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder: (context) => RegisterInformationPage(email: email),
          ),
        );
      } else {
        // Si el codigo es incorrecto mostrar error
        MensajeSnackbar.mostrarError(context, 'Código incorrecto.');
      }
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al verificar: ${e.toString()}');
    }
  }

  // Metodo para reenviar OTP
  Future<void> _reenviarOtp(BuildContext context, String email) async {
    try {
      // Solicitar reenvio OTP a Supabase
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      MensajeSnackbar.mostrarInfo(context, 'Se ha reenviado un nuevo código a tu correo.');

    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al reenviar código: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    // Devolver layout reutilizable y añadir contenido propio de cada pantalla
    return LoginRegisterLayout(
      // Icono circulo
      iconoSuperior: LineAwesomeIcons.comment_dots,
      // Altura de la pagina
      contentHeightFactor: 0.50,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Código de validación',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Revisa tu correo electrónico ($email)\n e ingresa el código de validación aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: custom.bordeContenedor.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 40),
            // Widget especial para codigos OTP
            OtpTextField(
              // 6 digitos (lo minimo requerido por Supabase)
              numberOfFields: 6,
              // Calcular ancho de cada campo dependiendo del ancho de la pantalla para que no se desborde
              fieldWidth: (MediaQuery.of(context).size.width - 70 - (5*10) ) / 6,
              // Estilos de borde en diferentes estados
              borderColor: custom.bordeContenedor.withValues(alpha: 0.10),
              enabledBorderColor: custom.bordeContenedor.withValues(alpha: 0.10),
              focusedBorderColor: custom.colorEspecial,
              borderWidth: 1.5,
              // Ver los campos en cajas separadas
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(16),
              // Espacio entre cajas
              margin: const EdgeInsets.symmetric(horizontal: 5),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              // Color de fondo del campo
              fillColor: custom.contenedor,
              // Activar el color de fondo
              filled: true,
              // Color del cursor
              cursorColor: custom.colorEspecial,
              // Habilitar el teclado numerico
              keyboardType: TextInputType.number,
              // Ejecutar metodo para verificar el OTP
              onSubmit: (String verificationCode) {
                verificarOtp(context, email, verificationCode);
              },
            ),
            const SizedBox(height: 50),
            // Poder reenviar el codigo si no se ha recibido
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No has recibido el código? ',
                  style: TextStyle(fontSize: 15, color: custom.bordeContenedor.withValues(alpha: 0.45)),
                ),
                // Gesture detector para detectar cuando se pulsa el texto
                GestureDetector(
                  onTap: () {
                    // Volver a llamar al metodo para enviar el codigo de nuevo
                     _reenviarOtp(context, email);
                  },
                  child: Text(
                    'Reenviar',
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
