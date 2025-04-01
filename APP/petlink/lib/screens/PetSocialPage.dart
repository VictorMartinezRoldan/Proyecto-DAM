import 'package:flutter/material.dart';

// CLASES
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/themes/customColors.dart';

class PetSocialPage extends StatefulWidget {
  const PetSocialPage({super.key});

  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  static List<PublicacionStyle> publicaciones = []; // LISTA DE PUBLICACIONES (PublicacionStyle) [LISTVIEW]

  // MÉTODO QUE LLAMA AL MÉTODO DE PUBLICACIONES PARA SOLICITAR PUBLICACIONES Y LAS AÑADE A LA LISTA DEL LISTVIEW
  void refrescar() async {
    List<Publicacion> datos = await Publicacion.solicitarPublicaciones(3); // NUMERO DE PUBLICACIONES QUE SE PIDEN
    for (Publicacion publicacion in datos){
      var indice = publicaciones.length;
      setState(() {
        publicaciones.add(PublicacionStyle(key: ValueKey(indice), publicacion: publicacion));
      });
    }
  }

  @override
  void initState(){
    super.initState();
    refrescar(); // EN LA CONSTRUCCIÓN REFRESCA CON NUEVAS IMÁGENES
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 15),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: custom.colorEspecial,
                shape: BoxShape.circle
              ),
              child: CircleAvatar(
                backgroundColor: custom.contenedor,
                child: Icon(Icons.person, color: custom.colorEspecial),
              )
            )
          ],
        ),
        leadingWidth: 60,
        actions: [
          IconButton(
            onPressed: (){
              refrescar();
            }, 
            icon: Icon(Icons.refresh))
        ],
        foregroundColor: custom.colorEspecial,
        backgroundColor: tema.surface,
        shadowColor: custom.sombraContenedor,
        title: IntrinsicWidth(
          child: Row(
            children: [
              Icon(Icons.pets),
              SizedBox(width: 10),
              Text("PETLINK", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Icon(Icons.pets),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: publicaciones.length,
          itemBuilder: (context, index) => publicaciones[index],
        )
      ),
    );
  }
}