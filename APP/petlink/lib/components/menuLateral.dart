import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petlink/components/cardSettingsStyle.dart';
import 'package:petlink/themes/customColors.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return SafeArea(
      child: Container(
        width: 325,
        decoration: BoxDecoration(
          color: tema.surface,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40))
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 15, left: 10),
              child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 30, color: custom.colorEspecial)
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20,
                bottom: 20,
                right: 20,
                top: 50,
              ),
              child: Column(
                children: [
                  // IMAGEN DE USUARIO
                  Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: custom.colorEspecial,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: custom.contenedor,
                      radius: 60,
                      //backgroundImage: CachedNetworkImageProvider("https://umiaxicevvhttszjoavu.supabase.co/storage/v1/object/public/imagenes/perfiles_usuario/profile6.png"),
                      child: Icon(Icons.person,size: 50,color: custom.colorEspecial,),
                    ),
                  ),
                  Text("NOMBRE", style: TextStyle(fontSize: 20)),
                  IntrinsicWidth(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 1,
                        top: 1,
                      ),
                      decoration: BoxDecoration(
                        color: custom.colorEspecial,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pets, size: 18, color: custom.contenedor),
                          SizedBox(width: 5),
                          Text(
                            "ID_USUARIO",
                            style: TextStyle(color: custom.contenedor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  CardSettingsStyle(
                    Icons.person,
                    "MI PERFIL",
                    "Ir a mi perfil",
                  ),
                  SizedBox(height: 20),
                  CardSettingsStyle(
                    Icons.pets,
                    "MASCOTAS",
                    "Ver o agregar tus mascotas",
                  ),
                  SizedBox(height: 20),
                  CardSettingsStyle(Icons.settings, "AJUSTES", "Ir a ajustes"),
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "CERRAR SESION",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
