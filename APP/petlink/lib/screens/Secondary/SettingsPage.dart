import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/components/cardSettingsStyle.dart';
import 'package:provider/provider.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:petlink/screens/Secondary/Settings/AccountInformationPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  void _toggleTheme(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(); // CAMBIAR EL TEMA
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Configuración",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
                CardSettingsStyle(
                Icons.person,
                "Información de la cuenta",
                "Datos personales y acceso",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountInformationPage()),
                  );
                },
                ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.language,
                "Idioma",
                "Cambia el idioma de la aplicación",
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personalización",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.brightness_6,
                "Modo Oscuro",
                "Cambia el tema de la aplicación",
                isSwitch: true,
                onSwitchChanged: _toggleTheme,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Notificaciones",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.notifications,
                "Preferencias de notificaciones",
                "Configura alertas y recordatorios",
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Privacidad y Seguridad",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.lock,
                "Privacidad de la cuenta",
                "Controla tus datos y permisos",
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.security,
                "Seguridad",
                "Protege tu cuenta",
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.logout,
                "Cerrar Sesión",
                "Salir de la aplicación",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
