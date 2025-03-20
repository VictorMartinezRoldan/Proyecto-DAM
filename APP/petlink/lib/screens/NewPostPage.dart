import 'package:flutter/material.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
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