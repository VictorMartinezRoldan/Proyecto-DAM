import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Provideridioma with ChangeNotifier {
  Locale _locale = const Locale('es');
  bool _cargando = true;
  String? _paisCacheTemporal; // Cache solo en memoria para la sesion actual

  Locale get locale => _locale;
  bool get cargando => _cargando;
  
  Future<void> establecerIdioma(Locale nuevoLocale) async {
    // Comprobar si el idioma es diferente al actual
    if (_locale != nuevoLocale) {
      _locale = nuevoLocale;
      // Guardar el nuevo idioma en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('idioma', nuevoLocale.languageCode);
      Intl.defaultLocale = nuevoLocale.toString(); // Cambiar idioma de Intl para la fecha de las publicaciones
      notifyListeners();
    }
  }

  // Método para establecer el idioma desde el menú de selección
  Future<void> cargarIdioma() async {
    _cargando = true;
    notifyListeners();
    
    try {
      // Cargar idioma guardado desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final codigoIdioma = prefs.getString('idioma');

      // Si hay un idioma guardado se utiliza, si no pasamos a detectar por ubicacion
      if (codigoIdioma != null) {
        _locale = Locale(codigoIdioma);
        print('Idioma guardado cargado: $codigoIdioma');
      } else {
        print('No se encontró idioma guardado, detectando por ubicación...');
        final idiomaDetectado = await _obtenerIdiomaPreferidoPorUbicacion();
        print('Idioma detectado por ubicación: $idiomaDetectado');
        _locale = Locale(idiomaDetectado);
      }
    } catch (e) {
      print('Error al cargar el idioma: $e');
      _locale = const Locale('es');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Metodo para hacer pruebas (se borrara mas adelante)
  Future<void> limpiarIdiomaGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idioma');
    print('Preferencia de idioma eliminada');
  }

  // Metodo para detectar el idioma por ubicacion
  Future<String> _obtenerIdiomaPreferidoPorUbicacion() async {
    try {
      print('Iniciando detección de idioma por ubicación...');
      
      // 1. Primero intentar con GPS (mas preciso)
      try {
        Position posicion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        
        List<Placemark> lugares = await placemarkFromCoordinates(
          posicion.latitude, 
          posicion.longitude
        );
        
        String pais = lugares.first.isoCountryCode ?? 'ES';
        print('País detectado por GPS: $pais');
        return _mapearPaisAIdioma(pais);
      } catch (errorGps) {
        print('Fallo en detección por GPS: $errorGps');
        
        // 2. Si falla el GPS, intentar con la ultima posicion conocida
        try {
          Position? ultimaPosicion = await Geolocator.getLastKnownPosition();
          if (ultimaPosicion != null) {
            List<Placemark> lugares = await placemarkFromCoordinates(
              ultimaPosicion.latitude, 
              ultimaPosicion.longitude
            );
            
            String pais = lugares.first.isoCountryCode ?? 'ES';
            print('País detectado por última posición conocida: $pais');
            return _mapearPaisAIdioma(pais);
          }
        } catch (errorUltimaPos) {
          print('Fallo al obtener última posición: $errorUltimaPos');
        }
        
        // 3. Si falla el GPS, intentamos geolocalizacion por IP mediante API
        return await _obtenerIdiomaPorIPActualizado();
      }
    } catch (e) {
      // Si falla todo devolvemos español por defecto
      print('Fallo completo en detección de ubicación: $e');
      return 'es';
    }
  }

  Future<String> _obtenerIdiomaPorIPActualizado() async {
    // Usar cache en memoria si existe (solo para esta sesión)
    if (_paisCacheTemporal != null) {
      return _mapearPaisAIdioma(_paisCacheTemporal!);
    }
    
    // API para hacer la geolocalizacion por IP
    // (En teoria esta API tiene peticiones ilimitadas, habra que ir probando)
    try {
      final respuesta = await http.get(
        Uri.parse('https://ipinfo.io/json?token=c044398147d2e9'),
        headers: {'Accept': 'application/json'}
      );
      
      // Comprobar que la respuesta de la API es correcta
      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        
        // Variable que contiene el pais detectado por IP
        String pais = datos['country'] ?? 'ES';
        print('País detectado por IP: $pais');
        
        // Guardar solo en memoria (no persiste al cerrar la app)
        _paisCacheTemporal = pais;
        
        return _mapearPaisAIdioma(pais);
      } else {
        print('Fallo en geolocalización por IP con estado: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('Fallo en geolocalización por IP: $e');
    }
    
    // Si falla devolvemos español
    return 'es';
  }

  // Mapear los codigos de los paises al idioma que corresponda
  String _mapearPaisAIdioma(String codigoPais) {
  switch (codigoPais.toUpperCase()) {
    case 'GB': case 'US': case 'AU': case 'CA': return 'en';
    case 'FR': return 'fr';
    case 'DE': return 'de';
    case 'IT': return 'it';
    case 'PT': case 'BR': return 'pt';
    case 'RU': return 'ru';
    case 'CN': return 'zh';
    case 'JP': return 'ja';
    case 'IN': return 'hi';
    case 'SA': case 'EG': case 'AE': case 'MA': return 'ar';
    case 'ES': case 'MX': case 'AR': case 'CO': return 'es';
    default: return 'es';
  }
}


  // Método para forzar nueva detección
  Future<void> redetectarIdioma() async {
    _paisCacheTemporal = null; // Limpiar cache de sesión
    await cargarIdioma(); // Volver a cargar
  }
}