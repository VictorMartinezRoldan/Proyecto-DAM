import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petlink/components/cardSettingsStyle.dart';
import 'package:petlink/screens/Secondary/FavoriteBreedsPage.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/SettingsPage.dart';
import 'package:petlink/screens/UserPage.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuLateral extends StatefulWidget {
  const MenuLateral({super.key});

  @override
  State<MenuLateral> createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    bool isLogin = SupabaseAuthService.isLogin.value; // Para saber si está la sesión iniciada o no
    
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
                      backgroundImage: (isLogin) ? CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil) : null, // Muestra la imagen de perfil del usuario
                      child: (!isLogin) ? Icon(Icons.person,size: 50,color: custom.colorEspecial,) : null,
                    ),
                  ),
                  // El nombre solo es visible si está login
                  Visibility(
                    visible: isLogin,
                    child: Text(
                      SupabaseAuthService.nombre, 
                      style: TextStyle(fontSize: 20)
                    ),
                  ),
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
                            (isLogin) ? SupabaseAuthService.nombreUsuario : "PETLINK",
                            style: TextStyle(color: custom.contenedor),
                          ),
                          SizedBox(width: 5),
                          (!isLogin) ? Icon(Icons.pets, size: 18, color: custom.contenedor) : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  CardSettingsStyle(
                    Icons.person,
                    AppLocalizations.of(context)!.lateralMenuProfileTitle,
                    (isLogin) ? AppLocalizations.of(context)!.lateralMenuProfileTitleDesc : AppLocalizations.of(context)!.lateralMenuProfileLogOutTitleDesc, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()));
                    },
                  ),
                  SizedBox(height: 20),
                  CardSettingsStyle(
                    Icons.favorite,
                    AppLocalizations.of(context)!.lateralMenuPetsTitle,
                    (isLogin) ? AppLocalizations.of(context)!.lateralMenuPetsTitleDesc : AppLocalizations.of(context)!.lateralMenuPetsLogOutTitleDesc, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FavouriteBreedsPage()));
                    },
                  ),
                  SizedBox(height: 20),
                  // Botón de ajustes
                  CardSettingsStyle(Icons.settings, AppLocalizations.of(context)!.lateralMenuSettingsTitle, AppLocalizations.of(context)!.lateralMenuSettingsTitleDesc, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    // LOGIN == CERRAR SESION / NO LOGIN == INICIAR SESION
                    child: TextButton(
                      onPressed: () async {
                        if (isLogin){
                          try {
                            await Supabase.instance.client.auth.signOut();
                            
                            if (!context.mounted) return;

                            setState(() {
                              SupabaseAuthService.isLogin.value = false;
                            });
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sesión cerrada')));
                          } catch (e){
                            // ERROR DE CIERRE DE SESIÓN
                          }
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        backgroundColor: (isLogin) ? Colors.redAccent : custom.colorEspecial,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ), 
                      child: Text(
                        (isLogin) ? AppLocalizations.of(context)!.lateralMenuLogOut : AppLocalizations.of(context)!.lateralMenuLogIn, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: (isLogin) ? Colors.white : custom.contenedor)),
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
