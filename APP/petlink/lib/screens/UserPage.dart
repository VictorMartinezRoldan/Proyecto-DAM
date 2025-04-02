import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/screens/Secondary/AuthController.dart';
import 'package:petlink/screens/Secondary/EditProfilePage.dart';
import 'package:petlink/screens/Secondary/SettingsPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/services/supabase_auth.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  late var custom; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  Map<String, dynamic>? datosUser; // DATOS DEL USUARIO

  @override
  void initState() {
    super.initState();
    authService.obtenerUsuario().then((datos) {
      if (datos != null) {
        setState(() {
          datosUser = datos;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    custom = Theme.of(context).extension<CustomColors>()!;
    tema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
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
                // IMAGEN DE PORTADA
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://vitakraft.es/wp-content/uploads/2020/12/Blog_HistoriaPerros-1110x600.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // CONTENEDOR CON SOMBRA
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
                // IMAGEN DE PERFIL
                Positioned(
                  bottom: -30, // AJUSTAR LA POSICIÓN SOBRE EL CONTENEDOR
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(
                        datosUser?['imagen_perfil'] ??
                            'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              datosUser?['nombre'] ?? 'Cargando...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 18, color: custom.colorEspecial),
                SizedBox(width: 8),
                Text(
                  '${datosUser?['nombre_usuario'] ?? 'usuario'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                datosUser?['descripcion'] ??
                    'Información no disponible. Por favor, actualiza tu perfil.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
              },
              icon: Icon(Icons.edit, color: custom.colorEspecial),
              label: Text(
                'Editar Perfil',
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
                  'Posts recientes',
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
        splashColor: custom.contenedor, // COMO UN BLANCO
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildPostGrid() {
    List<String> imageUrls = List.generate(
      9,
      (index) =>
          'https://eq2imhfmrcc.exactdn.com/wp-content/uploads/2016/08/golden-retriever.jpg?strip=all&lossy=1&ssl=1',
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrls[index], fit: BoxFit.cover),
        );
      },
    );
  }
}
