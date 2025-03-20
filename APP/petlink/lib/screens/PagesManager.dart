import 'package:flutter/material.dart';
import 'package:petlink/screens/NewPostPage.dart';
import 'package:petlink/screens/PetSocialPage.dart';
import 'package:petlink/screens/PetWikiPage.dart';
import 'package:petlink/screens/UserPage.dart';

class PagesManager extends StatefulWidget {
  const PagesManager({super.key});

  @override
  State<PagesManager> createState() => _PagesManagerState();
}

// CONTROLA LAS PAGINAS DE RED SOCIAL,
class _PagesManagerState extends State<PagesManager> {
  // ATRIBUTOS
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  // METODOS
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  
  // METODO PARA CAMBIAR DE PAGINA
  void _onItemTapped(int index) {
    if (index == 5){
      index = 3; // CAMBIAMOS PARA QUE NO FALLE
    }

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

  // INTERFAZ
  @override
  Widget build(BuildContext context) {
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
        selectedItemColor: tema.inversePrimary,
        unselectedItemColor: tema.secondary,
        iconSize: 27,

        // NO SE CREAN ESPACIOS ENTRE ICONOS EN LOS CAMBIOS DE INDICE
        type: BottomNavigationBarType.fixed,

        // ICONOS DEL NAVIGATION BAR
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],

        onTap: (value) {
          // PUBLICAR Y CAMARA SE GESTIONARARAN CON UN:
          // Navigator.push()
          if (value == 2){
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewPostPage()));
          } else if (value == 3) {
            
          } else {
            _onItemTapped(value);
          }
        },
      ),
    );
  }
}
