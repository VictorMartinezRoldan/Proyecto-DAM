import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

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
  colorScheme: ColorScheme.light(
    surface: Color.fromRGBO(242, 246, 255, 1),
    primary: Colors.black
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors.light
  ]
);

// --------------------------------------------------

// TEMA OSCURO

ThemeData darkmode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color.fromRGBO(24, 24, 24, 1),
    primary: Colors.white
  ),
  extensions: <ThemeExtension<dynamic>>[
    CustomColors.dark
  ]
);

// --------------------------------------------------