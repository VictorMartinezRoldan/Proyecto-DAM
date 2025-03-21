import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/Register.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  // ATRIBUTOS
  bool _showLogin = true;
  String _selected = "Login";

  // METODOS

  // INTERFAZ GRAFICA
  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    return Scaffold(
      backgroundColor: tema.inverseSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LOGO Y NOMBRE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logos/petlink_white.png", width: 80),
                const SizedBox(width: 10),
                const Text("PETLINK",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // FOTO PERRO
            //Flexible(fit: FlexFit.loose, child: Image.asset("assets/perro_blackmode.png", width: 100)),
            // CONTENEDOR BLANCO
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tema.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      // SELECTOR DE PESTAÑA
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          const ButtonSegment(value: "Login", label: Text("Login")),
                          const ButtonSegment(value: "Register", label: Text("Register")),
                        ],
                        selected: {_selected},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selected = newSelection.first;
                            if (_selected == "Login"){
                              _showLogin = true;
                            } else {
                              _showLogin = false;
                            }
                          });
                        },
                        // ESTILO DE LOS BOTONES DE PESTAÑA
                        style: ButtonStyle(
                          side: const WidgetStatePropertyAll(
                            BorderSide(
                              width: 0,
                              color: Color.fromARGB(255, 230, 230, 230)
                            ),
                          ),
                          animationDuration: const Duration(seconds: 0),
                          backgroundColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return tema
                                  .inversePrimary; // Color de fondo cuando está seleccionado
                            } else {
                              return Color.fromARGB(255, 230, 230, 230); // Color de fondo cuando NO está seleccionado
                            }
                          }),
                          foregroundColor: WidgetStateColor.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return tema
                                  .surface; // Color del texto cuando está seleccionado
                            } else {
                              return Colors.grey.shade700; // Color del texto cuando NO está seleccionado
                            }
                          }),
                        ),
                      ),
                    ),
                    // CONTENIDO DE LAS PESTAÑAS
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _showLogin ? LoginPage() : RegisterPage(), // CARGA UNA U OTRA
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
