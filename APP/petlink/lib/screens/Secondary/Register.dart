import 'package:flutter/material.dart';
import 'package:petlink/components/blueButton.dart';
import 'package:petlink/components/myTextField.dart';
import 'package:petlink/components/myTextFieldPassword.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        MyTextField(hintString: "Usuario",),
        SizedBox(height: 10),
        MyTextFieldPassword(),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: MyTextField(hintString: "Nombre")),
            SizedBox(width: 10),
            Expanded(child: MyTextField(hintString: "Apellidos"))
          ],
        ),
        SizedBox(height: 20),
        BlueButton(text: "REGISTRARSE")
      ],
    );
  }
}