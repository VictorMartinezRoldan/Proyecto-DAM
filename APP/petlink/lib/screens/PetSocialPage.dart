import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// CLASES
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/components/menuLateral.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/themes/customColors.dart';

class PetSocialPage extends StatefulWidget {
  const PetSocialPage({super.key});

  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  static List<PublicacionStyle> publicaciones = []; // LISTA DE PUBLICACIONES (PublicacionStyle) [LISTVIEW]

  // MÉTODO QUE LLAMA AL MÉTODO DE PUBLICACIONES PARA SOLICITAR PUBLICACIONES Y LAS AÑADE A LA LISTA DEL LISTVIEW
  Future<void> refrescar() async {
    List<Publicacion> datos = await Publicacion.solicitarPublicaciones(context, 3); // NUMERO DE PUBLICACIONES QUE SE PIDEN
    for (Publicacion publicacion in datos){
      var indice = publicaciones.length;
      if (!mounted) {
        return;
      }
      setState(() {
        publicaciones.add(PublicacionStyle(key: ValueKey(indice), publicacion: publicacion));
      });
    }
  }

  @override
  void initState(){
    super.initState();
    refrescar(); // EN LA CONSTRUCCIÓN REFRESCA CON NUEVAS IMÁGENES
    SupabaseAuthService.isLogin.addListener(reconstruir);
  }

  // Cuando se reconstruye limpia las listas y publicaciones para recargarlas con los likes guardados
  void reconstruir() async{
    publicaciones.clear();
    Publicacion.publicacionesExistentes.clear();
    setState(() {
      // RECONSTRUIMOS
      refrescar();
    });
  }

  @override
  void dispose() {
    super.dispose();
    SupabaseAuthService.isLogin.removeListener(reconstruir); // IMPORTANTE
  }

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
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
                backgroundImage: (SupabaseAuthService.isLogin.value) ? CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil) : null,
                child: (!SupabaseAuthService.isLogin.value) ? Icon(Icons.person,size: 25,color: custom.colorEspecial,) : null,
              )
            )
          ],
        ),
        leadingWidth: 60,
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
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: tema.surface,
          color: custom.colorEspecial,
          displacement: 5,
          onRefresh: refrescar,
          child: ListView.builder(
            itemCount: publicaciones.length,
            itemBuilder: (context, index) => publicaciones[index],
          ),
        ),
      ),
      endDrawer: MenuLateral(),
      //drawer: Drawer(),
    );
  }
}