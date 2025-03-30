import 'package:flutter/material.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/themes/customColors.dart';

class PetSocialPage extends StatefulWidget {
  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: tema.surface,
        backgroundColor: custom.colorEspecial,
        title: Text("PetSocialPage", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => PublicacionStyle(),
        )
      ),
    );
  }
}