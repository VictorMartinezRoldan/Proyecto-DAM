import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/screens/Secondary/EditProfilePage.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/RegisterPage.dart';
import 'package:petlink/screens/Secondary/SettingsPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:petlink/themes/themeProvider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  Map<String, dynamic>? datosUser;
  List<String> userPosts = [];

  @override
void initState() {
  super.initState();
  SupabaseAuthService.isLogin.addListener(reconstruir);
}


  @override
  void dispose() {
    super.dispose();
    SupabaseAuthService.isLogin.removeListener(reconstruir); // IMPORTANTE
  }

  void reconstruir() async{
    setState(() {
      // RECONSTRUIMOS
    });
  }

  Future<void> _cargarPublicaciones() async {
    if (datosUser == null || datosUser?['id'] == null) {
      print("⛔ datosUser es null o no tiene ID");
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('publicaciones')
          .select('imagen_url')
          .eq('id_usuario', datosUser!['id']);

      print("📡 Respuesta de Supabase: $response");

      if (response.isNotEmpty) {
        setState(() {
          userPosts = response
              .map((post) => post['imagen_url'] as String?)
              .whereType<String>()
              .toList();
        });
      } else {
        print("⚠️ No hay publicaciones para este usuario.");
      }
    } catch (e) {
      print("❌ Error obteniendo publicaciones: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    custom = Theme.of(context).extension<CustomColors>()!;
    tema = Theme.of(context).colorScheme;

    // Si no esta logueado se muestra el widget usuarionologueado
  if (!SupabaseAuthService.isLogin.value) {
    return Scaffold(
      body: usuarioNoLogueado(context),
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileTitle,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LineAwesomeIcons.cog, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.imagenPortada : 'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: tema.surface,
                      boxShadow: [
                        BoxShadow(
                          color: tema.surface.withOpacity(1.0),
                          spreadRadius: 40,
                          blurRadius: 30,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: custom.colorEspecial,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: custom.contenedor,
                      radius: 60,
                      backgroundImage: (SupabaseAuthService.isLogin.value) ? CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil) : null,
                      child: (!SupabaseAuthService.isLogin.value) ? Icon(Icons.person,size: 50,color: custom.colorEspecial,) : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.nombre : 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 18, color: custom.colorEspecial),
                SizedBox(width: 8),
                Text(
                  (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.nombreUsuario : 'Nombre de usuario no disponible',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                (SupabaseAuthService.isLogin.value) ? SupabaseAuthService.descripcion : 'Descripción no disponible',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
                if (result == true) {
                  setState(() {}); // RECARGAR DATOS SI SE ACTUALIZO EL PERFIL
                }
              },
              icon: Icon(Icons.edit, color: custom.colorEspecial),
              label: Text(
                AppLocalizations.of(context)!.editProfile,
                style: TextStyle(color: custom.colorEspecial),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: custom.colorEspecial, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  AppLocalizations.of(context)!.recentPosts,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: _buildPostGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    if (SupabaseAuthService.publicaciones.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noPublication));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: SupabaseAuthService.publicaciones.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: CachedNetworkImageProvider(SupabaseAuthService.publicaciones[index]),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

Widget usuarioNoLogueado(BuildContext context) {
  final custom = Theme.of(context).extension<CustomColors>()!;
  final tema = Theme.of(context).colorScheme;
  final logo = "assets/logos/petlink_${(Provider.of<ThemeProvider>(context).isLightMode) ? "black" : "grey"}.png";

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen o logo decorativo
          Image.asset(
            logo,
            height: 100,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24),
          Text(
            '¡Bienvenid@ a PetLink!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: tema.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Para ver tu perfil y tus publicaciones, inicia sesión en tu cuenta.',
            style: TextStyle(
              fontSize: 16,
              color: tema.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: Icon(Icons.login, color: tema.onPrimary),
              label: Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tema.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: custom.colorEspecial,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              icon: Icon(Icons.person_add, color: custom.colorEspecial),
              label: Text(
                'Crear cuenta nueva',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: custom.colorEspecial,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: custom.contenedor,
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: custom.colorEspecial,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

