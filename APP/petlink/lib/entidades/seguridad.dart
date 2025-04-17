import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:petlink/components/dialogoInformacion.dart';
import 'package:petlink/components/dialogoPregunta.dart';
import 'package:petlink/screens/Secondary/AuthController.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Seguridad {
  static List<String> badWordsSpanish = [
  'puta', 'puto', 'put@', 'pu7a', 'pu1a', 'pu*a', 'pvt@', 'putamadre', 'puta madre', 'ptm',
  'mierda', 'm13rd4', 'm1erda', 'mi3rda', 'mrd',
  'gilipollas', 'g1lip0llas', 'gil1p0llas', 'g1l1p0llas',
  'cabrón', 'cabron', 'kbron', 'kabron', 'cabro0n', 'c4br0n',
  'estúpido', 'estupido', 'estup1do', 'estvpido', 'estüpid0',
  'idiota', '1d10t4', 'id1ota',
  'imbécil', 'imbecil', '1mbecil', 'imb3cil',
  'coño', 'cono', 'coñ0', 'c0ñ0', 'c0n0',
  'hostia', 'h0stia', 'j0stia',
  'joder', 'j0der', 'xoder',
  'maricón', 'maricon', 'm4ricon', 'm@ricon', 'mar1con', 'mariquita',
  'pendejo', 'pend3jo', 'p3nd3jo',
  'zorra', 'z0rr4', 'z@rra', 'zorr4',
  'perra', 'p3rra', 'p@rra',
  'mamón', 'mamon', 'mam0n', 'mamonazo',
  'retrasado', 'retardado', 'r3trasado', 'ret@rdado',
  'chupapollas', 'chup4p0llas', 'chupap0llas',
  'pedo', 'ped0', 'cagada', 'c4gada',
  'malparido', 'm4lparid0', 'm@lparido',
  'hdp', 'hijo de puta', 'h1jo de puta', 'h!jo d3 pvt@', "hija de puta"
  'csm', 'ctm', 'ctmr', 'csmr', 'me cago en',
  "muerte", "te mueras", "ostia", "ojalá te", "pulgoso", "de estar muertos",
  "muerto", "muerta", "tus muertos", "sarnoso", "hijueputa", "gonorrea", "infierno", "chandoso",
  'imbecil de mierda', 'asqueroso', 'asq3ros0', 'cerdo', 'animala', 'bastardo', 'b4st4rd0',
  'mierdoso', 'm13rd0s0', 'maldito', 'm4ld1t0', 'maldita', 'desgraciado', 'basura', 'cagón',
  'chinga tu madre', 'vete a la mierda', 'vete al demonio', 'lameculos', 'ladilloso',
  'arrastrado', 'huelepedos', 'chupamedias', 'pelotudo', 'forro', 'idiot4',
  'chucho', 'pulguiento', 'bestia', 'animal de mierda',
  'perro de mierda', 'perro sarnoso', 'perra asquerosa', 'maldito chucho', 'chucho callejero',
  'te voy a patear', 'te atropello', 'lo abandono', 'lo mato',
  'te enveneno el perro', 'ese perro es basura', 
  // SEXUALES
  "sexo", "te cogía", "te follaría", "tia buena",
  "te la metía", "meterla", "hacertelo", "hacértelo", "hacía el amor", "hacer el amor",
  'chupada', 'chupamela', 'chupamela toda', 'chup4d4', 'chvpad4',
  'lamida', 'lamemela', 'lamela', 'metemela', 'mete el pito',
  'venirse', 'eyacular', 'correrse', 'te corres', 'me corro',
  'pene', 'p3ne', 'verga', 'v3rg4', 'vergas', 'vergudo',
  'pito', 'p1t0', 'p1to', 'p1t@', 'pitin',
  'culo', 'cul0', 'kulo', 'qlo', 'ort0',
  'ano', 'a.n.o', 'a*n*o',
  'vagina', 'vajina', 'v4g1n4', 'vajin4', 'chocho', 'concha', 'c0nch4', 'conch4',
  'coño', 'k0ñ0', 'konyo',
  'teta', 'tetas', 'tetas gordas', 'tetona', 'tetotas', 'tetita',
  'pezón', 'pezones', 'pez0n', 'pezon', 'p3zon',
  'hacerle el delicioso', 'hacer el sin respeto', 'darle sin miedo',
  'partirle el queso', 'montarla', 'montárselo', 'echar un polvo', 'polvo', 'fajarse',
  'encuerarse', 'encuerado', 'desnudarse', 'desnudo', 'encima de mí', 'encima tuyo',
  'putona', 'putilla', 'putita', 'put0n4', 'pvt@', 'putear',
  'calentona', 'ninfómana', 'ninfomana', 'n1nf0',
  'sexo oral', 'sexo anal', 'anal', '69', 'trío', 'orgía', 'orgasmo',
  'eyaculación', 'eyaculando', 'le eché', 'le metí',
  's3x0', 's3xo', 's*x0', 's3xual', 'f0llar', 'f*llar', 'c0ger', 'coj3r', 'chvpada', 'v4g1n4', 'verg4', 'vrg', 'pvt4', 't3tas', 'ch0cho',
  'hentai', 'tetas grandes', 'sexo duro', 'sexo salvaje', 'sexo rudo', 'me lo metes', 'me penetra', 'me folla', 'me la mete',
  'me la chupas', 'te la chupo', 'sexo sucio', 'sexo caliente',
  'estás caliente', 'estoy caliente', 'te calientas', 'te mojo', 'mojada', 'me mojé', 'te mojaste',
  ];

  static List<String> badWordsEnglish = [
  'fuck', 'f*ck', 'fck', 'f**k', 'fu*k', 'fuk', 'fuxk', 'fukc', 'fuk u', 'f you', 'f u',
  'motherfucker', 'm0therfucker', 'mthrfcukr', 'muthafucka',
  'shit', 'sh1t', 'sh*t', 'sh!t', 'sht',
  'asshole', 'assh0le', 'a55hole', 'aSShole', 'a**hole',
  'bitch', 'b1tch', 'b!tch', 'b*tch', 'b!+ch',
  'bastard', 'b@stard', 'bast4rd',
  'dick', 'd1ck', 'd!ck', 'd!k', 'd*ck',
  'pussy', 'pu55y', 'p*ssy', 'pUssy',
  'cunt', 'c*nt', 'c**t', 'kunt',
  'crap', 'cr@p', 'cr4p',
  'slut', 'slvt', 's1ut', 'sl*t',
  'whore', 'wh0re', 'wh@re', 'w#ore',
  'retard', 'r3tard', 'r*tard',
  'dumbass', 'dumb@ss', 'dumb4ss',
  'prick', 'pr1ck', 'pr!ck',
  'jerk', 'j3rk', 'j3rkoff',
  'moron', 'm0ron', 'm0r0n',
  'loser', 'l0ser', 'l0z3r',
  'suck my', 'suck it', 'suckdick', 'suckcock',
  'go to hell', 'burn in hell', 'die bitch', 'kill yourself', 'kms', 'kys',
  'douche', 'douchebag', 'twat', 'shithead', 'faggot', 'f@ggot', 'nutjob',
  'perv', 'pedo', 'molester', 'rapist', 'jerking', 'wanker', 'arsehole', 'bollocks',
  'cum', 'cumshot', 'deepthroat', 'blowjob', 'bj', '69', 'doggy style', 'doggystyle',
  'anal', 'horny', 'sext', 'nude', 'boobs', 'tits', 'nipple', 'clit', 'sex', 'naked',
  ];

  static Future<bool> validate(BuildContext context, String frase) async{
    final lowerInput = frase.toLowerCase();
    if (badWordsSpanish.any((word) => lowerInput.contains(word)) ||
      badWordsEnglish.any((word) => lowerInput.contains(word))) {
      // DIALOGO DE ADVERTENCIA DE LENGUAJE INAPROPIADO
      await showDialog(
        context: context, 
        builder: (context) => DialogoInformacion(
          icono: Icon(Icons.warning_rounded, size: 90, color: Colors.redAccent),
          titulo: "Lenguaje inapropiado", 
          texto: "Tu publicación infringe nuestras normas de convivencia.\n\nPor favor, evita el uso de lenguaje ofensivo, vulgar o inapropiado.\n\nSi este comportamiento se repite, tu cuenta podría ser suspendida o baneada.", 
          textoBtn: "Voy a corregirlo",
          ColorBtn: Colors.redAccent,
        ),
      );
      return false; // FALSE = NO A PASADO LA VALIDACIÓN
    } else {
      return true;
    }
  }

  // Si no está login no puede dar like... comentar... publicar..., eso se controla aquí
  static Future<bool> canInteract(BuildContext context) async{
    // ¡Ups! Para comentar, dar likes o publicar, inicia sesión o crea una cuenta.
    if (SupabaseAuthService.isLogin.value){
      return true; // PUEDE PUBLICARs
    } else {
      bool? result = await showDialog<bool>(
        context: context, 
        builder: (context) => DialogoPregunta(
          imagen: Image.asset("assets/perros_dialogos/info_triste_${(Provider.of<ThemeProvider>(context).isLightMode) ? "light" : "dark"}.png"),
          titulo: "Inicia sesión para continuar", 
          texto: "Para comentar, dar likes o publicar, inicia sesión o crea una cuenta", 
          textoBtn1: "Más tarde", 
          textoBtn2: "Vamos a ello"
        )
      );
      if (result == true){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuthController()),
        );
      }
      return false; // NO PUEDE
    }
  }

  // Método para checkear si el usuario tiene conexión a internet
  static Future<bool> comprobarConexion() async {
    final conexion = await Connectivity().checkConnectivity();
    if (conexion == ConnectionState.none) {
      return false;
    } else {
      try {
        final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 5));
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        // ERROR DE CONEXION
      }
      return false;
    }
  }

  // Método para comprimir imágenes
  static Future<Uint8List?> comprimirImagen(File imagen) async {
    final Uint8List? imagenComprimida = await FlutterImageCompress.compressWithFile(
      imagen.path,
      quality: 60,
      format: CompressFormat.jpeg
    );

    return imagenComprimida;
  }
}