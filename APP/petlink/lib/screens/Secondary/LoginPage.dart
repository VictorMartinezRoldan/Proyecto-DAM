import 'package:flutter/material.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/components/myTextFieldPassword.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _login(BuildContext context, String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login exitoso')));
        SupabaseAuthService().obtenerUsuario();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Column(
      children: [
        SizedBox(height: 10),
        MyTextField(hintString: "Correo", controller: emailController),
        SizedBox(height: 10),
        MyTextFieldPassword(controller: passwordController),
        SizedBox(height: 20),
        BlueButton(
          text: "INICIAR SESION",
          onPressed: () => _login(context, emailController.text, passwordController.text),
        ),
      ],
    );
  }
}
