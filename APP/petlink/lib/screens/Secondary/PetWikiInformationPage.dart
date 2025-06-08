import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:petlink/components/ejercicioHorasStyle.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:icons_plus/icons_plus.dart';

class PetWikiInformationPage extends StatefulWidget {
  // Mapa con los datos de la raza
  final Map<String, dynamic>? razaData;

  const PetWikiInformationPage({super.key, this.razaData});

  @override
  State<PetWikiInformationPage> createState() => _PetWikiInformationPageState();
}

class _PetWikiInformationPageState extends State<PetWikiInformationPage> {

  // Indicador para saber si una raza es favorita o no
  bool esFavorito = false;
  // Controlador carrusel de imagenes
  PageController _controladorPagina = PageController();
  // Indice actual del carrusel de imagenes
  int _indiceImagenActual = 0;

  // Almacenar la informacion procesada de una raza
  Map<String, dynamic> razaInfo = {};

  @override
  void initState() {
    super.initState();
    // Cargar los datos al iniciar el widget
    _inicializarDatosRaza();
    _verificarFavorito();
  }

  // Metodo para iniciar los datos de una raza
  Future<void> _inicializarDatosRaza() async {

    // Lista que almacena las urls de las imagenes de Supabase
    List<String> imagenesCarrusel = [];

    // Si existen datos de la raza se obtienen las imagenes de Supabase mediante el metodo nombreNormalizado
    if (widget.razaData != null && widget.razaData!['raza'] != null) {
      final supabase = Supabase.instance.client;
      final String nombreRaza = widget.razaData!['raza'];
      final String nombreNormalizado = _normalizarNombre(nombreRaza);
      final String path = 'imagenes_biografia/$nombreNormalizado';

      try {
        // Obtener lista de archivos de la carpeta de su raza
        final archivos = await supabase.storage
            .from('imagenes')
            .list(path: path);

        // Filtrar archivos y obtener la url publica de Supabase
        imagenesCarrusel = archivos .where((f) => !f.name.startsWith('.'))
                .map((f) => supabase.storage.from('imagenes').getPublicUrl('$path/${f.name}')).toList();

      } catch (e) {
        imagenesCarrusel = [];
      }
    }

    // Si no hay una imagen valida usar un placeholder
    if (imagenesCarrusel.isEmpty) {
      imagenesCarrusel = [
        'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
      ];
    }

    // Procesar las imagenes
    String imagenBio = '';
    if (widget.razaData != null) {
      if (widget.razaData!['bio_imagen'] != null &&
          widget.razaData!['bio_imagen'].toString().isNotEmpty) {
        imagenBio = widget.razaData!['bio_imagen'] as String;
      }
      if (imagenBio.isEmpty && widget.razaData!['ico_imagen'] != null) {
        imagenBio = widget.razaData!['ico_imagen'] as String;
      }

      // Procesar los problemas de salud separandolos por las comas
      List<String> problemasSalud = [];
      if (widget.razaData!['problemas_salud'] != null &&
          widget.razaData!['problemas_salud'].toString().isNotEmpty) {
        String problemasString = widget.razaData!['problemas_salud'] as String;
        problemasSalud = problemasString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Procesar los consejos
      String datoConsejo = '';
      if (widget.razaData!['consejos'] != null &&
          widget.razaData!['consejos'].toString().isNotEmpty) {
        datoConsejo = widget.razaData!['consejos'] as String;
      }

      // Procesar los datos curiosos
      String datoCurioso = '';
      if (widget.razaData!['datos_curiosos'] != null &&
          widget.razaData!['datos_curiosos'].toString().isNotEmpty) {
        datoCurioso = widget.razaData!['datos_curiosos'] as String;
      }

      // Actualizar el estado con toda la informacion recibida y procesada
      setState(() {
        razaInfo = {
          'nombre': widget.razaData!['raza'] ?? 'Raza desconocida',
          'imagenes': imagenesCarrusel,
          'bio_imagen': imagenBio,
          'descripcion':
              widget.razaData!['descripcion'] ?? 'Sin descripción disponible',
          'tipoRaza': widget.razaData!['tipo'] ?? 'No especificado',
          'tamanoMacho': widget.razaData!['tamaño_macho'] ?? 'No especificado',
          'tamanoHembra':
              widget.razaData!['tamaño_hembra'] ?? 'No especificado',
          'peso': widget.razaData!['peso'] ?? 'No especificado',
          'origen': widget.razaData!['origen'] ?? 'No especificado',
          'esperanzaVida':
              widget.razaData!['esperanza_vida'] ?? 'No especificado',
          'horasEjercicio':
              widget.razaData!['horas_ejercicio'] ?? 'No especificado',
          'amigabilidadNinos':
              (widget.razaData!['amigabilidad_niños'] as num?)?.toInt() ?? 0,
          'amigabilidadPerros':
              (widget.razaData!['amigabilidad_perros'] as num?)?.toInt() ?? 0,
          'problemasSalud': problemasSalud,
          'consejo': datoConsejo,
          'curiosidad': datoCurioso,
        };
      });
    }
  }

  // Normalizar el nombre de la raza de perro para las rutas de archivos en Supabase quitando caracteres especiales etc
  String _normalizarNombre(String nombre) {
    final withNoAccents = nombre
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 _-]'), '')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
    return withNoAccents
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Verificar si la raza es favorita en el usuario
  Future<void> _verificarFavorito() async {
  final userId = SupabaseAuthService.id;
  if (userId == null || userId.isEmpty || widget.razaData == null) return;

  try {
    final response = await Supabase.instance.client
        .from('raza_favorito')
        .select()
        .eq('id_usuario', userId)
        .eq('raza', widget.razaData!['raza'])
        .limit(1); // Así lo tienes en el ejemplo funcional

    final existeFavorito = response != null && (response as List).isNotEmpty;

    if (mounted) {
      setState(() {
        esFavorito = existeFavorito;
      });
    }
  } catch (e) {
    debugPrint('Error al verificar favorito: $e');
  }
}

  // Alternar el estado de favorito, permitiendo agregar o quitar una raza de favoritos
  Future<void> _alternarFavorito() async {
  final userId = SupabaseAuthService.id;
  if (userId == null || userId.isEmpty || widget.razaData == null) {
    MensajeSnackbar.mostrarError(context, 'Debes iniciar sesión para agregar favoritos');
    return;
  }

  final nuevoEstado = !esFavorito;

  setState(() {
    esFavorito = nuevoEstado;
  });

  try {
    if (nuevoEstado) {
      // Agregar a favoritos
      await Supabase.instance.client.from('raza_favorito').insert({
        'id_usuario': userId,
        'raza': widget.razaData!['raza'],
        // Solo agrega otros campos si existen en la tabla
      });
    } else {
      // Remover de favoritos
      await Supabase.instance.client
          .from('raza_favorito')
          .delete()
          .eq('id_usuario', userId)
          .eq('raza', widget.razaData!['raza']);
    }

    if (mounted) {
      MensajeSnackbar.mostrarInfo(
        context,
        esFavorito ? 'Agregado a favoritos' : 'Eliminado de favoritos',
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        esFavorito = !nuevoEstado;
      });
      MensajeSnackbar.mostrarError(context, 'Error al actualizar favoritos');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Verificar si los datos estan disponibles y si no mostrar cargando
    if (razaInfo.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    // Contenido principal
    return Scaffold(
      // Permitir que el contenido se posicione por detras del appbar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Eliminar sombra interior
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        forceMaterialTransparency: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: custom.sombraContenedor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // Boton favoritos appbar
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: custom.sombraContenedor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _alternarFavorito,
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imagenes
            Stack(
              children: [
                Container(
                  height: 340,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _controladorPagina,
                    itemCount: razaInfo['imagenes'].length,
                    onPageChanged: (index) {
                      setState(() {
                        _indiceImagenActual = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: razaInfo['imagenes'][index],
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.grey[600],
                                      size: 50,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error al cargar imagen',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
                // Degradado en la parte del nombre de la raza
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Indicadores de pagina
                if (razaInfo['imagenes'].length > 1)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 290),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          razaInfo['imagenes'].length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _indiceImagenActual == index
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Texto nombre raza
                Positioned(
                  bottom: 45,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        razaInfo['nombre'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: custom.colorEspecial,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Resto del contenido
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: custom.contenedor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: custom.sombraContenedor.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirSeccion(
                        'Descripción',
                        custom.colorEspecial,
                        child: ExpandableText(
                          razaInfo['descripcion'],
                          expandText: '\nVer más ↓',
                          collapseText: '\nVer menos ↑',
                          maxLines: 6,
                          linkColor: custom.colorEspecial,
                          animation: true,
                          animationDuration: Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: tema.onSurface.withValues(alpha: 0.8),
                          ),
                          linkStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: custom.colorEspecial,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _construirFiltroAdaptable(
                              CachedNetworkImage(
                                imageUrl:
                                    widget.razaData!['bio_imagen'] ??
                                    'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                                fit: BoxFit.contain,
                                placeholder:
                                    (context, url) => Container(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: custom.colorEspecial,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(
                                          Icons.pets,
                                          color: Colors.grey[600],
                                          size: 50,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _construirSeccion(
                        'Información Básica',
                        custom.colorEspecial,
                        child: _construirCuadriculaInfo(tema),
                      ),
                      const SizedBox(height: 25),
                      _construirSeccion(
                        'Amigabilidad',
                        custom.colorEspecial,
                        child: Column(
                          children: [
                            _construirContenedorAmigabilidad(
                              'Niños',
                              razaInfo['amigabilidadNinos'],
                              MingCute.baby_line,
                              custom.colorEspecial,
                            ),
                            const SizedBox(height: 20),
                            _construirContenedorAmigabilidad(
                              'Perros',
                              razaInfo['amigabilidadPerros'],
                              MingCute.bone_fill,
                              custom.colorEspecial,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                     _construirSeccion(
                      'Problemas de salud comunes',
                      custom.colorEspecial,
                      child: razaInfo['problemasSalud'].isEmpty
                          ? Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: tema.primary.withAlpha(128), // 0.5 * 255 ≈ 128
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'No hay problemas de salud registrados',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: tema.onSurface.withAlpha(153), // 0.6 * 255 ≈ 153
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...razaInfo['problemasSalud'].asMap().entries.map(
                                  (entry) {
                                    final problema = entry.value;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            custom.colorEspecial.withAlpha(204),
                                            custom.contenedor,
                                          ],
                                          stops: const [0.0, 0.22],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: custom.sombraContenedor.withAlpha((0.4 * 255).toInt()),
                                            blurRadius: 4,
                                            offset: const Offset(0, 7),
                                          ),
                                          BoxShadow(
                                            color: custom.sombraContenedor.withAlpha((0.95 * 255).toInt()),
                                            blurRadius: 4,
                                            offset: const Offset(0, -1),
                                            spreadRadius: -2,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              MingCute.heartbeat_2_fill,
                                              color: custom.contenedor,
                                              size: 30,
                                            ),
                                            const SizedBox(width: 16),
                                            // Texto con Marquee
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20, left: 22),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 2),
                                                    LayoutBuilder(
                                                      builder: (context, constraints) {
                                                        final textPainter = TextPainter(
                                                          text: TextSpan(
                                                            text: problema,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: tema.onSurface.withAlpha(242),
                                                              fontWeight: FontWeight.w500,
                                                              height: 1.3,
                                                            ),
                                                          ),
                                                          textDirection: TextDirection.ltr,
                                                          maxLines: 1,
                                                        );
                                                        textPainter.layout(
                                                          maxWidth: constraints.maxWidth,
                                                        );
                                                        final isTextOverflowing = textPainter.didExceedMaxLines;
                                                        if (isTextOverflowing) {
                                                          return SizedBox(
                                                            height: 24,
                                                            child: Marquee(
                                                              text: problema,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: tema.onSurface.withAlpha(242),
                                                                fontWeight: FontWeight.w500,
                                                                height: 1.3,
                                                              ),
                                                              scrollAxis: Axis.horizontal,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              blankSpace: 50.0,
                                                              velocity: 35.0,
                                                              pauseAfterRound: const Duration(seconds: 2),
                                                              startPadding: 0.0,
                                                              accelerationDuration: const Duration(seconds: 1),
                                                              accelerationCurve: Curves.linear,
                                                              decelerationDuration: const Duration(milliseconds: 500),
                                                              decelerationCurve: Curves.easeOut,
                                                              fadingEdgeStartFraction: 0.05,
                                                              fadingEdgeEndFraction: 0.05,
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                            problema,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: tema.onSurface.withAlpha(242),
                                                              fontWeight: FontWeight.w500,
                                                              height: 1.3,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ),
                      const SizedBox(height: 25),
                      _construirSeccion(
                        'Horas de ejercicio recomendadas',
                        custom.colorEspecial,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: BarraHorasEjercicio(
                            horasEjercicio:
                                razaInfo['horasEjercicio'] ?? 'No especificado',
                            imageUrl:
                                'https://i.postimg.cc/vmSfhTY5/a8f5bff5-09c0-420c-a527-545e9606ff6a.png',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _construirSeccion(
                        'Consejos',
                        custom.colorEspecial,
                        child:
                            (razaInfo['consejo']?.isEmpty ?? true)
                                ? Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: tema.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'No hay consejos registrados',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: tema.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: custom.colorEspecial.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: custom.colorEspecial.withValues(
                                        alpha: 0.20,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    razaInfo['consejo'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: tema.onSurface,
                                    ),
                                  ),
                                ),
                      ),

                      const SizedBox(height: 25),
                      _construirSeccion(
                        'Datos curiosos',
                        custom.colorEspecial,
                        child:
                            (razaInfo['curiosidad']?.isEmpty ?? true)
                                ? Row(
                                  children: [
                                    Icon(
                                      Icons.psychology_outlined,
                                      color: tema.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'No hay datos curiosos registrados',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: tema.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : ExpandableText(
                                  razaInfo['curiosidad'],
                                  expandText: '\nVer más ↓',
                                  collapseText: '\nVer menos ↑',
                                  maxLines: 6,
                                  linkColor: custom.colorEspecial,
                                  animation: true,
                                  animationDuration: Duration(
                                    milliseconds: 300,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: tema.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  linkStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: custom.colorEspecial,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para separar las secciones y tener una mejor organizacion
  Widget _construirSeccion(String title, Color accentColor, {required Widget child}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Contenido de cada seccion
        child,
      ],
    );
  }

  // Widget para la seccion de informacion basica
  Widget _construirCuadriculaInfo(ColorScheme tema) {
    final infoItems = [
      {
        'label': 'Tipo',
        'value': razaInfo['tipoRaza'],
        'icon': Icons.pets,
        'color': Colors.pink[50],
      },
      {
        'label': 'Tamaño ♂',
        'value': razaInfo['tamanoMacho'],
        'icon': Icons.straighten,
        'color': Colors.blue[50],
      },
      {
        'label': 'Tamaño ♀',
        'value': razaInfo['tamanoHembra'],
        'icon': Icons.straighten,
        'color': Colors.purple[50],
      },
      {
        'label': 'Peso',
        'value': razaInfo['peso'],
        'icon': MingCute.balance_fill,
        'color': Colors.teal[50],
      },
      {
        'label': 'Origen',
        'value': razaInfo['origen'],
        'icon': Icons.public,
        'color': Colors.orange[50],
      },
      {
        'label': 'Esperanza de vida',
        'value': razaInfo['esperanzaVida'],
        'icon': CupertinoIcons.heart_fill,
        'color': Colors.red[50],
      },
    ];

    // Cuadricula de 3 columas
    return GridView.count(
      crossAxisCount: 3,
      // Permitir que el grid se ajuste al contenido
      shrinkWrap: true,
      // Evitar scroll interno
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: infoItems.map((item) => _construirTarjetaInfo(item, tema)).toList(),
    );
  }

  // Widget para construir individualmente cada tarjete de informacion basica
  Widget _construirTarjetaInfo(Map<String, dynamic> item, ColorScheme tema) {
    final custom = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: custom.contenedor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: custom.sombraContenedor.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: custom.sombraContenedor.withValues(alpha: 0.95),
            blurRadius: 4,
            offset: const Offset(0, -1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  item['label'] ?? '',
                  style: TextStyle(
                    color: tema.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item['value'] ?? 'N/A',
                    style: TextStyle(
                      color: tema.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: item['color'] ?? Colors.grey[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: custom.sombraContenedor.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: 40,
                height: 40,
                child: Icon(item['icon'], color: Colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir contenedor de amigabilidad de los perros
  Widget _construirContenedorAmigabilidad(String label,int rating,IconData icon,Color accentColor) {

    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: custom.contenedor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: custom.sombraContenedor.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: custom.sombraContenedor.withValues(alpha: 0.95),
            blurRadius: 4,
            offset: const Offset(0, -1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: tema.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Icon(
                          Icons.pets,
                          color:
                              i < rating
                                  ? custom.colorEspecial
                                  : tema.onSurface.withValues(alpha: 0.3),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$rating/5',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para aplicar efectos de color de bio_imagen adaptandolo al fondo del tema
  Widget _construirFiltroAdaptable(Widget child) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          Color.fromRGBO(48, 48, 48, 1),
          BlendMode.multiply,
        ),
        child: child,
      );
    } else {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.9,
          0.0,
          0.1,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.04,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]),
        child: child,
      );
    }
  }

  @override
  void dispose() {
    // Liberar al destruir el widget
    _controladorPagina.dispose();
    super.dispose();
  }
}
