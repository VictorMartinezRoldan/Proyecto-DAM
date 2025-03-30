import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class PetWikiPage extends StatefulWidget {
  @override
  State<PetWikiPage> createState() => _PetWikiPageState();
}

class _PetWikiPageState extends State<PetWikiPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("PetWikiPage", style: TextStyle(color: tema.primary, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }
}