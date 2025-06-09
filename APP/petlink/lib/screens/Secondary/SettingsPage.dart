import 'package:flutter/material.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/screens/PagesManager.dart';
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
  late var custom =
      Theme.of(
        context,
      ).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  void _toggleTheme(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(); // CAMBIAR EL TEMA
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin = SupabaseAuthService.isLogin.value;

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
                Icons.notifications,
                AppLocalizations.of(context)!.settingsNotificationPreferences,
                AppLocalizations.of(
                  context,
                )!.settingsNotificationPreferencesDesc,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.securityTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.lock,
                AppLocalizations.of(context)!.settingsPrivacy,
                AppLocalizations.of(context)!.settingsPrivacyDesc,
              ),
              const SizedBox(height: 15),
              CardSettingsStyle(
                Icons.security,
                AppLocalizations.of(context)!.settingsSecurity,
                AppLocalizations.of(context)!.settingsSecurityDesc,
              ),
              const SizedBox(height: 15),
              // Logout, solo visible si el usuario esta logueado
              Visibility(
                visible: isLogin,
                child: Column(
                  children: [
                    CardSettingsStyle(
                      Icons.logout,
                      AppLocalizations.of(context)!.settingsLogout,
                      AppLocalizations.of(context)!.settingsLogoutDesc,
                      onTap: () async {
                        try {
                          await Supabase.instance.client.auth.signOut();
                          setState(() {
                            SupabaseAuthService.isLogin.value = false;
                          });

                          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => PagesManager()),
                            (route) => false,
                          );
                          MensajeSnackbar.mostrarInfo(context, 'Sesión cerrada');
                        } catch (e) {
                          MensajeSnackbar.mostrarError(context, 'Error al cerrar sesión');
                        }
                      },
                    ),
                  ],
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
