import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';

class ComentariosPage extends StatefulWidget {
  final Publicacion publicacion;
  const ComentariosPage({super.key, required this.publicacion});

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  
  @override
  Widget build(BuildContext context) {
    //TEMAS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    bool soloTexfield = (MediaQuery.of(context).viewInsets.bottom != 0);
    Publicacion publi = widget.publicacion;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Esto es clave
      extendBody: true,
      appBar: AppBar(
        //backgroundColor: custom.contenedor,
        foregroundColor: custom.colorEspecial,
        actions: [
          Row(
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
          SizedBox(width: 10),
        ],
        title: Text("Publicación", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40)
          ),
          color: custom.contenedor
        ),
        child: PublicacionStyle(publicacion: publi, isComentariosPage: true),
      ),
    );
  }
}