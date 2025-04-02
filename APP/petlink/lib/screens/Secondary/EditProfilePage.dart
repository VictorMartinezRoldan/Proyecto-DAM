import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/screens/UserPage.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  File? _imagenPortada; // VARIABLE PARA LA IMAGEN DE PORTADA
  File? _imagenPerfil; // VARIABLE PARA LA IMAGEN DE PERFIL
  final TextEditingController _controladorNombre = TextEditingController(text: "Usuario");
  final TextEditingController _controladorDescripcion = TextEditingController(text: "Descripción corta del usuario.");

  final ImagePicker _seleccion = ImagePicker(); // INICIALIZAR EL IMAGE PICKER

  Future<void> _seleccionarImagen(bool esPortada) async {
    final imagenSeleccionada = await _seleccion.pickImage(
      source: ImageSource.gallery,
    );

    if (imagenSeleccionada != null) {
      setState(() {
        if (esPortada) {
          _imagenPortada = File(imagenSeleccionada.path);
        } else {
          _imagenPerfil = File(imagenSeleccionada.path);
        }
      });
    }
  }

  void _guardarPerfil() {
    // Logica
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
        actions: [
          TextButton(
            onPressed: _guardarPerfil,
            child: Text("Guardar", style: TextStyle(color: Colors.blue, fontSize: 18)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _seleccionarImagen(true),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: _imagenPortada != null
                          ? DecorationImage(image: FileImage(_imagenPortada!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imagenPortada == null
                        ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => _seleccionarImagen(false),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: _imagenPerfil != null
                            ? FileImage(_imagenPerfil!)
                            : AssetImage("assets/profile_placeholder.png") as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _controladorNombre,
                    decoration: InputDecoration(labelText: "Nombre"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _controladorDescripcion,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: "Descripción"),
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
