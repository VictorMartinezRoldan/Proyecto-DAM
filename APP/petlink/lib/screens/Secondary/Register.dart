import 'package:flutter/material.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/components/myTextFieldPassword.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Future<void> _register(BuildContext context, String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro exitoso')));
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
        SizedBox(height: 10),
        SizedBox(height: 20),
        BlueButton(
          text: "REGISTRARSE",
          onPressed: () => _register(context, emailController.text, passwordController.text),
        )
      ],
    );
  }
}