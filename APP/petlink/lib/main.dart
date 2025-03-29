import 'package:flutter/material.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://umiaxicevvhttszjoavu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtaWF4aWNldnZodHRzempvYXZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwMjUwNTgsImV4cCI6MjA1ODYwMTA1OH0.S27RkemMF0qexe-7dEYTLxnrXbyblXGSZ8fg2x0Hb1I',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: provider.Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PETLINK',
            debugShowCheckedModeBanner: false,
            home: PagesManager(), // Mostrar una pantalla de carga inicial
            theme: themeProvider.themeData,
          );
        },
      ),
    );
  }
}