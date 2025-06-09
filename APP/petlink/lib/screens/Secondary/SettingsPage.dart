import 'package:flutter/material.dart';
import 'package:petlink/components/dialogoDisponibilidadFutura.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/Settings/SelectLanguagePage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/components/cardSettingsStyle.dart';
import 'package:provider/provider.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:petlink/screens/Secondary/Settings/AccountInformationPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  void _toggleTheme(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(); // CAMBIAR EL TEMA
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin = SupabaseAuthService.isLogin.value;
    late var custom =Theme.of(context,).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

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
                  AppLocalizations.of(context)!.configTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              // Informacion de la cuenta, solo visible si esta logueado
              Visibility(
                visible: isLogin,
                child: Column(
                  children: [
                    CardSettingsStyle(
                      Icons.person,
                      AppLocalizations.of(context)!.settingsAccountInformation,
                      AppLocalizations.of(context)!.settingsAccountInformationDesc,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountInformationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isLogin)
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.language,
                AppLocalizations.of(context)!.settingsLanguage,
                AppLocalizations.of(context)!.settingsLanguageDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectLanguagePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.personalizationTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.brightness_6,
                AppLocalizations.of(context)!.settingsDarkMode,
                AppLocalizations.of(context)!.settingsDarkModeDesc,
                isSwitch: true,
                onSwitchChanged: _toggleTheme,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.notificationTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                onTap: () async {
                  await showDialog(context: context, builder: (context) => DialogoDisponibilidadFutura());
                },
                Icons.notifications,
                AppLocalizations.of(context)!.settingsNotificationPreferences,
                AppLocalizations.of(
                  context,
                )!.settingsNotificationPreferencesDesc,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                // LOGIN == CERRAR SESION / NO LOGIN == INICIAR SESION
                child: TextButton(
                  onPressed: () async {
                    if (isLogin){
                      try {
                        await Supabase.instance.client.auth.signOut();
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
