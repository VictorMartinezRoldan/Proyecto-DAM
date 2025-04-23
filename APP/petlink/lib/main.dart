import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/screens/StartingAnimation.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_size/window_size.dart';
import 'package:petlink/components/providerIdioma.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://umiaxicevvhttszjoavu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtaWF4aWNldnZodHRzempvYXZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwMjUwNTgsImV4cCI6MjA1ODYwMTA1OH0.S27RkemMF0qexe-7dEYTLxnrXbyblXGSZ8fg2x0Hb1I',
  );
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(425, 750)); // Tamaño mínimo de la ventana
  }

  // Cargar el idioma guardado
  final localeProvider = Provideridioma();
  await localeProvider.cargarIdioma();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SupabaseAuthService().obtenerUsuario();
    
    return Consumer2<ThemeProvider, Provideridioma>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'PETLINK',
          debugShowCheckedModeBanner: false,
          home: StartingAnimation(),
          theme: themeProvider.themeData,
          
          // Configuración de internacionalizacion
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
          ],
          
          // Opcional: Para manejar mejor el redimensionado de texto
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Fija la escala de texto
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}