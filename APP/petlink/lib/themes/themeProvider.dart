import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // TEMA INICIAL DE LA APP
  ThemeData _themeData = lightmode;

  // Setter Theme
  ThemeData get themeData => _themeData; // return _themeData;

  // Getter Theme
  set themeData(ThemeData themedata) {
    _themeData = themedata;
    // Actualizar interfaz
    notifyListeners();
  }

  // is light mode / para controlar si está activado un tema o no en settings
  bool get isLightMode => _themeData == lightmode;

  // Intercambiar tema
  void toggleTheme() {
    if (_themeData == lightmode) {
      themeData = darkmode;
    } else {
      themeData = lightmode;
    }
  }
}

// --------------------------------------------------

// TEMA CLARO

ThemeData lightmode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color.fromRGBO(242, 246, 255, 1),
    primary: Colors.black,
    secondary: Colors.grey.shade500,
    inversePrimary: Color.fromRGBO(0, 96, 255, 1),
    // inversePrimary: Color.fromRGBO(47, 0, 255, 1), // MORADO AZULADO
    onPrimaryContainer: Colors.white
  )
);

// --------------------------------------------------

// TEMA OSCURO

ThemeData darkmode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.white,
    secondary: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade500
  )
);

// --------------------------------------------------