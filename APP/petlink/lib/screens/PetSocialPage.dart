// BIBLIOTECAS
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petlink/components/dialogoDisponibilidadFutura.dart';
import 'package:petlink/entidades/seguridad.dart';

// CLASES
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/components/menuLateral.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PetSocialPage extends StatefulWidget {
  const PetSocialPage({super.key});

  @override
  State<PetSocialPage> createState() => _PetSocialPageState();
}

class _PetSocialPageState extends State<PetSocialPage> {
  static List<PublicacionStyle> publicaciones = []; // LISTA DE PUBLICACIONES (PublicacionStyle) [LISTVIEW]
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); // Para control endDrawer
  Set<int> publicacionesVistas = {}; // PARA CONTROLAR LAS PUBLICACIONES YA VISTAS EN EL DETECTOR Y HACER LLAMADAS ÚNICAS
  bool solicitando = false;
  bool isFinal = false;
  // ---------------------------------
  // ---------------------------------
  int numeroPublicaciones = 10;
  // ---------------------------------
  // ---------------------------------

  // MÉTODO QUE LLAMA AL MÉTODO DE PUBLICACIONES PARA SOLICITAR PUBLICACIONES Y LAS AÑADE A LA LISTA DEL LISTVIEW
  Future<void> refrescar() async {
    solicitando = true;
    List<Publicacion> datos = await Publicacion.solicitarPublicaciones(context, numeroPublicaciones); // NUMERO DE PUBLICACIONES QUE SE PIDEN
    for (Publicacion publicacion in datos){
      var indice = publicaciones.length;
      if (!mounted) {
        return;
      }
      setState(() {
        publicaciones.add(PublicacionStyle(key: ValueKey(indice), publicacion: publicacion));
      });
    }
    solicitando = false;
    if (datos.isEmpty) {
      isFinal = true;
    }
  }


  @override
  void initState(){
    super.initState();
    refrescar(); // EN LA CONSTRUCCIÓN REFRESCA CON NUEVAS IMÁGENES
    SupabaseAuthService.isLogin.addListener(reconstruir);
  }

  // Cuando se reconstruye limpia las listas y publicaciones para recargarlas con los likes guardados
  Future<void> reconstruir() async{
    isFinal = false;
    solicitando = false;
    publicacionesVistas.clear();
    publicaciones.clear();
    Publicacion.idPublicacionesExistentes.clear();
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
      key: scaffoldKey,
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                await showDialog(context: context, builder: (context) => DialogoDisponibilidadFutura());
              }, 
              icon: Icon(Icons.notifications_none_rounded, size: 30)
            )
          ]
        ),
        leadingWidth: 80,
        actions: [
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openEndDrawer(),
            child: Row(
              children: [
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
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
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
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: tema.surface,
          color: custom.colorEspecial,
          displacement: 5,
          onRefresh: reconstruir,
          child: ListView.builder(
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  VisibilityDetector(
                    key: Key("publicacion_${Seguridad.generarID()}"), 
                    child: publicaciones[index], 
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction > 0.7) {
                        if (!publicacionesVistas.contains(index)) {
                          publicacionesVistas.add(index);
                          if (index + 1 > (publicaciones.length - 3) && !solicitando && !isFinal) {
                            refrescar();
                          }
                        }
                      }
                    }
                  )
                ],
              );
            }
          ),
        ),
      ),
      endDrawer: MenuLateral(),
    );
  }
}