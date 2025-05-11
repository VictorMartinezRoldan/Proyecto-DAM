import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/NewPostPage.dart';
import 'package:petlink/screens/PetSocialPage.dart';
import 'package:petlink/screens/PetWikiPage.dart';
import 'package:petlink/screens/PetlinkCamera.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/screens/UserPage.dart';
import 'package:petlink/themes/customColors.dart';

class PagesManager extends StatefulWidget {
  const PagesManager({super.key});

  @override
  State<PagesManager> createState() => _PagesManagerState();
}

// CONTROLA LAS PAGINAS DE RED SOCIAL
class _PagesManagerState extends State<PagesManager> {
  // Permite controlar la navegación dentro de un PageView
  final PageController _pageController = PageController();
  
  int _selectedIndex = 0;

  late final StreamSubscription _connectionSub;


  // METODOS
  
  // METODO PARA CAMBIAR DE PAGINA
  void _onItemTapped(int index) {

    setState(() {
      _selectedIndex = index;
    });

    // CAMBIA DE PAGINA CON ANIMACION
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();

    // Listener para cuando el wifi o datos se activa / desactiva
    _connectionSub = Connectivity().onConnectivityChanged.listen((result) async {
      bool isConnected = await Seguridad.comprobarConexion();
      if (!isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage())
        );
      }
    });

    // LISTENER PARA CUANDO CAMBIA DE PANTALLA
    _pageController.addListener(() {
      int newIndex = _pageController.page!.round();
      if (newIndex != _selectedIndex) {
        setState(() {
          if (newIndex == 2){
            _selectedIndex = 4;
          } else {
            _selectedIndex = newIndex;
          }
        });
      }
    });
  }

  // ANIMACION PAGINA POST
  void gotoNewPostPage(){
    Navigator.push(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NewPostPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation, 
            curve: Curves.easeOut)),
            alignment: Alignment(0.0, 0.95),
            child: Align(
              alignment: Alignment.center,
              child: child,
            ),
            )
      )
    );
  }


  // INTERFAZ
  @override
  Widget build(BuildContext context) {
    // ATRIBUTOS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // PAGINAS DE LA APP
          PetSocialPage(),
          PetWikiPage(),
          UserPage(),
        ],
      ),
      // NAVEGADOR DE ABAJO COMPARTIDO
      bottomNavigationBar: BottomNavigationBar(

        // INDICE EN EL QUE SE ESTÁ
        currentIndex: _selectedIndex,

        // NO SE MUESTRAN LOS LABELS DE LOS ICONOS
        showSelectedLabels: false,
        showUnselectedLabels: false,

        // COLORES DE LOS ICONOS
        selectedItemColor: custom.colorEspecial,
        unselectedItemColor: Colors.grey.shade500,
        iconSize: 27,

        // NO SE CREAN ESPACIOS ENTRE ICONOS EN LOS CAMBIOS DE INDICE
        type: BottomNavigationBarType.fixed,

        // ICONOS DEL NAVIGATION BAR
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: ""),                 // 0
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: ""), // 1
          BottomNavigationBarItem(icon: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: custom.colorEspecial,
            ),
            child: Icon(Icons.add, color: tema.surface),
          ), label: ""),     // 2
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: ""),  // 3
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),               // 4
        ],

        onTap: (value) async {
          // PUBLICAR Y CAMARA SE GESTIONARARAN CON UN:
          // Navigator.push()
          if (value == 2){
            if(await Seguridad.canInteract(context)){
              gotoNewPostPage();
            }
          } else if (value == 3) {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => PetlinkCamera())
              );
          } else {
            _onItemTapped(value); // CAMBIAR DE VENTANA CON ANIMACIÓN
          }
        },
      ),
    );
  }
}
