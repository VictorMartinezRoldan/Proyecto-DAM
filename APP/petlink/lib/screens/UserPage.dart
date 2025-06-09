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
  final String? idUsuario;
  const UserPage({super.key, this.idUsuario});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  Map<String, dynamic>? datosUser;
  List<String> userPosts = [];
  bool esPerfilPropio = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SupabaseAuthService.isLogin.addListener(reconstruir);
    _inicializarPerfil();
  }

  @override
  void dispose() {
    super.dispose();
    SupabaseAuthService.isLogin.removeListener(reconstruir); // IMPORTANTE
  }

  void reconstruir() async {
    setState(() {
      // RECONSTRUIMOS
    });
  }

  // Inicializar perfil segun userId
  Future<void> _inicializarPerfil() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Si no hay userId, mostrar perfil del usuario logueado
      if (widget.idUsuario == null) {
        esPerfilPropio = true;
        if (SupabaseAuthService.isLogin.value) {
          datosUser = {
            'id': SupabaseAuthService.id,
            'nombre': SupabaseAuthService.nombre,
            'nombre_usuario': SupabaseAuthService.nombreUsuario,
            'descripcion': SupabaseAuthService.descripcion,
            'imagen_perfil': SupabaseAuthService.imagenPerfil,
            'imagen_portada': SupabaseAuthService.imagenPortada,
            'correo': SupabaseAuthService.correo,
          };
          userPosts = SupabaseAuthService.publicaciones;
        }
      } else {
        // Mostrar perfil de otro usuario
        esPerfilPropio = widget.idUsuario == SupabaseAuthService.id;
        datosUser = await authService.obtenerUsuarioPorId(widget.idUsuario!);
        if (datosUser != null) {
          userPosts = await authService.obtenerPublicacionesPorUsuario(
            widget.idUsuario!,
          );
        }
      }
    } catch (e) {
      print("❌ Error inicializando perfil: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          userPosts =
              response
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

    // Solo mostrar pantalla de login si es perfil propio y no esta logueado
    if (!SupabaseAuthService.isLogin.value && widget.idUsuario == null) {
      return Scaffold(body: usuarioNoLogueado(context));
    }

    // Mostrar loading mientras carga los datos
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            esPerfilPropio
            ? "Mi Perfil"
            : datosUser != null 
            ? "Perfil de ${datosUser!['nombre'] ?? 'Usuario'}"
            : "Cargando perfil...",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: custom.colorEspecial),
        ),
      );
    }
    // Si no se encontraron datos del usuario
    if (datosUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.profileTitle,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: tema.onSurface.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Usuario no encontrado',
                style: TextStyle(
                  fontSize: 18,
                  color: tema.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esPerfilPropio
              ? "Mi Perfil"
              : "Perfil de ${datosUser!['nombre'] ?? 'Usuario'}",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // Mostrar configuracion solo para perfil propio
        actions:
            esPerfilPropio
                ? [
                  IconButton(
                    icon: Icon(LineAwesomeIcons.cog, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                  ),
                ]
                : null,
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
                        datosUser!['imagen_portada'] ??
                            'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
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
                      // Imagen de perfil
                      backgroundImage:
                          datosUser!['imagen_perfil'] != null
                              ? CachedNetworkImageProvider(
                                datosUser!['imagen_perfil'],
                              )
                              : null,
                      child:
                          datosUser!['imagen_perfil'] == null
                              ? Icon(
                                Icons.person,
                                size: 50,
                                color: custom.colorEspecial,
                              )
                              : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Mostrar informacion
            Text(
              datosUser!['nombre'] ?? 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 18, color: custom.colorEspecial),
                SizedBox(width: 8),
                Text(
                  datosUser!['nombre_usuario'] ??
                      'Nombre de usuario no disponible',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                datosUser!['descripcion'] ?? 'Descripción no disponible',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 15),
            // Mostrar boton editar perfil unicamente si es perfil propio
            if (esPerfilPropio) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                  if (result == true) {
                    _inicializarPerfil();
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
            ],
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
    //  Mostrar las publicaciones
    if (userPosts.isEmpty) {
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
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: CachedNetworkImageProvider(
              userPosts[index],
            ),
            fit: BoxFit.cover,
          ),
        );
      },
    );
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
            Image.asset(logo, height: 100, fit: BoxFit.contain),
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
                  side: BorderSide(color: custom.colorEspecial, width: 1.5),
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
}
