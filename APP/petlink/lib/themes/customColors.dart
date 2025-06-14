import 'package:flutter/material.dart';

// CLASE QUE CONTIENE LOS COLORES PERSONALIZADOS CON ETIQUETAS PERSONALIZADAS

@immutable
class CustomColors extends ThemeExtension<CustomColors> {

  // DEFINIMOS LOS NOMBRES

  // FONDO Y TEXTO EN (themeProvider)
  final Color colorEspecial;
  final Color contenedor;
  final Color sombraContenedor;
  final Color bordeContenedor;
  final Color fondoSuave;
  final Color textoSuave;
  // Color.fromRGBO(0, 16, 42, 1)

  const CustomColors({
    required this.colorEspecial,
    required this.contenedor,
    required this.sombraContenedor,
    required this.bordeContenedor,
    required this.fondoSuave,
    required this.textoSuave,
  });

  @override
  CustomColors copyWith({
    Color? colorEspecial,
    Color? contenedor,
    Color? sombraContenedor,
    Color? bordeContenedor,
    Color? fondoSuave,
    Color? textoSuave,
  }) {
    return CustomColors(
      colorEspecial: colorEspecial ?? this.colorEspecial,
      contenedor: contenedor ?? this.contenedor,
      sombraContenedor: sombraContenedor ?? this.sombraContenedor,
      bordeContenedor: bordeContenedor ?? this.bordeContenedor,
      fondoSuave: fondoSuave ?? this.fondoSuave,
      textoSuave: textoSuave ?? this.textoSuave,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      colorEspecial: Color.lerp(colorEspecial, other.colorEspecial, t)!,
      contenedor: Color.lerp(contenedor, other.contenedor, t)!,
      sombraContenedor: Color.lerp(sombraContenedor, other.sombraContenedor, t)!,
      bordeContenedor: Color.lerp(bordeContenedor, other.bordeContenedor, t)!,
      fondoSuave: Color.lerp(fondoSuave, other.fondoSuave, t)!,
      textoSuave: Color.lerp(textoSuave, other.textoSuave, t)!,
    );
  }

  // DEFINICIÓN DE COLORES PARA TEMA CLARO Y OSCURO

  // --------------------------------------------------

  // TEMA CLARO
  static const light = CustomColors(
    colorEspecial: Color.fromRGBO(0, 96, 255, 1),
    contenedor: Colors.white,
    sombraContenedor: Color.fromRGBO(224, 224, 224, 1),
    bordeContenedor: Colors.black,
    fondoSuave: Color(0xFFe1ecfe),
    textoSuave: Color(0xFF5c9aff)
  );

  // --------------------------------------------------

  // TEMA OSCURO

  static const dark = CustomColors(
    colorEspecial: Colors.white,
    contenedor: Color.fromRGBO(48, 48, 48, 1),
    sombraContenedor: Color.fromRGBO(77, 77, 77, 1),
    bordeContenedor: Colors.white,
    fondoSuave: Color(0xFF484848),
    textoSuave: Color(0xFFb4b4b4)
  );

  // --------------------------------------------------
}
