import 'package:flutter/material.dart';

class PetSocialPage extends StatefulWidget {
  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("PetSocialPage", style: TextStyle(color: tema.primary, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }
}