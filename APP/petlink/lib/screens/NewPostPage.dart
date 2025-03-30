import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    return Scaffold(
      appBar: AppBar(
        foregroundColor: tema.primary,
      ),
      body: Center(
        child: Text("NewPostPage", style: TextStyle(color: tema.primary, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }

}