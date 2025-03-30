import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/screens/Secondary/AuthController.dart';
import 'package:petlink/themes/customColors.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); 
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        */
        title: Text(
          'Perfil',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LineAwesomeIcons.cog, size: 30),
            onPressed: () {
              // Acción para abrir ajustes
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Nombre Apellidos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@usuario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Paseador profesional 🦮 | 15 perros me consideran su "tio favorito" | Expert@ en evitar peleas por palos en el parque 🌳 #DogWalkerLife',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit, color: custom.colorEspecial),
                label: Text(
                  'Editar Perfil',
                  style: TextStyle(color: custom.colorEspecial),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: custom.colorEspecial,
                    width: 2,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posts recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildPostGrid(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthController(),
            ), // Asegúrate de que AuthController sea la página deseada
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
      (index) => 'https://eq2imhfmrcc.exactdn.com/wp-content/uploads/2016/08/golden-retriever.jpg?strip=all&lossy=1&ssl=1',
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
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
    
  }
}