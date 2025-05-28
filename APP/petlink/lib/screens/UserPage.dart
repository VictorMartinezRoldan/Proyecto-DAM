import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/screens/Secondary/AuthController.dart';
import 'package:petlink/screens/Secondary/EditProfilePage.dart';
import 'package:petlink/screens/Secondary/SettingsPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  // Verificar si el usuario esta logueado, y si no lo esta llevarle al inicio de sesión
  if (!SupabaseAuthService.isLogin.value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthController()),
      );
    });
  }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthController()),
          );
        },
        backgroundColor: custom.colorEspecial,
        splashColor: custom.contenedor,
        child: Icon(Icons.person_add),
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
