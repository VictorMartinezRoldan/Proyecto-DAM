import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/RegisterPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  bool _showLogin = true;
  String _selected = "Login";

Future<void> _register(BuildContext context, String email, String password) async {
  try {
    final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
    if (response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
    }
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de autenticación: ${e.message}')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inesperado: ${e.toString()}')));
  }
}


  Future<void> _login(String email, String password) async {
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _toggleAuthPage(String selected) {
    if (mounted) {
      setState(() {
        _selected = selected;
        _showLogin = selected == "Login";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 16, 42, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: tema.surface),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/logos/petlink_white.png", width: 80),
                const SizedBox(width: 10),
                const Text("PETLINK",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tema.surface, // Fondo del contenedor principal
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity, // TAMAÑO DE LOGIN / REGISTER
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: "Login", label: Text("Login")),
                          ButtonSegment(value: "Register", label: Text("Register")),
                        ],
                        selected: {_selected},
                        onSelectionChanged: (newSelection) => _toggleAuthPage(newSelection.first),
                        style: ButtonStyle(
                          side: const WidgetStatePropertyAll(
                            BorderSide(width: 0, color: Color.fromARGB(255, 230, 230, 230)),
                          ),
                          animationDuration: const Duration(seconds: 0),
                          backgroundColor: WidgetStateColor.resolveWith((states) =>
                              states.contains(WidgetState.selected)
                                  ? custom.colorEspecial
                                  : const Color.fromARGB(255, 230, 230, 230)),
                          foregroundColor: WidgetStateColor.resolveWith((states) =>
                              states.contains(WidgetState.selected)
                                  ? tema.surface
                                  : Colors.grey.shade700),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showLogin ? const LoginPage() : const RegisterPage(),
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
