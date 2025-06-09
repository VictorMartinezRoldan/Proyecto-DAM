import 'package:flutter/material.dart';
import 'package:petlink/components/buscadorRazas.dart';
import 'package:petlink/components/tarjetaRazaStyle.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/FavoriteBreedsPage.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/screens/Secondary/PetWikiInformationPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/services/supabase_auth.dart';

class PetWikiPage extends StatefulWidget {
  const PetWikiPage({super.key});

  @override
  State<PetWikiPage> createState() => _PetWikiPageState();
}

class _PetWikiPageState extends State<PetWikiPage> {
  // Lista para cagar todas las razas
  List<Map<String, dynamic>> todasLasRazas = [];
  // Lista para las razas mostradas actuales
  List<Map<String, dynamic>> razasMostradas = [];
  // Razas despues de aplicar los filtros
  List<Map<String, dynamic>> listaRazasFiltradas = [];

  // Cuantas tarjetas mostrar inicialmente
  int _elementosMostrados = 6;
  // Incrementar la carga de las tarjetas
  final int _incremento = 6;
  // Estado de la carga de las tarjetas
  bool _cargandoMas = false;
  bool _cargando = false;

  final ScrollController _scrollController = ScrollController();
  final userId = SupabaseAuthService.id;

  @override
  void initState() {
    super.initState();
    // Cargar los datos inicialmente
    _cargarTodasLasRazas();
    // Listener para scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Liberar los recursos del controlador
    _scrollController.dispose();
    super.dispose();
  }

  // Metodo para cargar las razas desde la BD
  Future<void> _cargarTodasLasRazas() async {
  setState(() => _cargando = true);

  try {
    // Verificar conexión antes de realizar la consulta
    bool isConnected = await Seguridad.comprobarConexion();
    if (!isConnected) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NetworkErrorPage()),
        );
      }
      return;
    }

    // Seleccionar todos los campos de la tabla perros para su posterior utilizacion
    final respuesta = await Supabase.instance.client
        .from('perros')
        .select('*')
        .order('raza', ascending: true);

    if (mounted) {
      setState(() {
        // Convertirlo a lista
        todasLasRazas = respuesta.cast<Map<String, dynamic>>();
        // Inicializar los primeros elementos
        _mostrarMasElementos();
        _cargando = false;
      });
    }
  } catch (e) {
    // Verificar conexión en caso de error también
    bool isConnected = await Seguridad.comprobarConexion();
    if (!isConnected && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NetworkErrorPage()),
      );
    }
    
    if (mounted) {
      setState(() => _cargando = false);
    }
  }
}


  // Metodo para mostrar mas elementos en la lista
  void _mostrarMasElementos() {
    // Calcular el indice final
    final fin = _elementosMostrados.clamp(0, todasLasRazas.length);

    // Verificar mounted antes de setState
    if (mounted) {
      setState(() {
        razasMostradas = todasLasRazas.take(fin).toList();
        listaRazasFiltradas = razasMostradas;
        _cargandoMas = false;
      });
    }
  }

  // Metodo para cunado el usuario hace scroll
  void _onScroll() {
    // Cuando el usuario hace scroll comprueba que el usuariop esta cerca del final
    // Comprueba si se esta cargando mas contenido, si quedan mas razas por mostrar o si hay filtros activos
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_cargandoMas &&
        razasMostradas.length < todasLasRazas.length &&
        listaRazasFiltradas == razasMostradas) {
      // Unicamente carga mas si no hay filtros activos

      // Indicar que se estan cargando mas elementos
      if (mounted) {
        setState(() => _cargandoMas = true);
      }

      // Delay para cargar mas elementos y que la pantalla se vea mas fluida
      Future.delayed(Duration(milliseconds: 200), () {
        // Aumentar la cantidad de elementos a mostrar
        _elementosMostrados += _incremento;
        // Llamar al metodo para mostrar mas elementos
        _mostrarMasElementos();
      });
    }
  }

  // Metodo para actualizar la lista de razas filtradas
  void _actualizarResultados(List<Map<String, dynamic>> resultados) {
    // Actualizar estado de la interfaz para ver los filtrados
    setState(() => listaRazasFiltradas = resultados);
  }

  // Encabezado de la pagina
  Widget _headerAnimado(Color colorEspecial, Color primary) {
    final color = colorEspecial;

    return Column(
      // Alinear el contenido a la izquierda
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Descubre",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        const Text(
          "El mundo canino",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          width: 60,
          height: 4,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temas de la app
    late var custom =
        Theme.of(
          context,
        ).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

    final colorEspecial = custom.colorEspecial;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tema.surface,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Wiki de Razas",
          style: TextStyle(
            color: custom.colorEspecial,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Cuerpo principal
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.5),
        child: ListView(
          controller: _scrollController,
          children: [
            const SizedBox(height: 5),
            _headerAnimado(custom.colorEspecial, custom.contenedor),
            const SizedBox(height: 10),
            // Widget para filtrar datos de las razas
            BuscadorRazas(
              textoSugerencia: "Buscar raza...",
              datosOriginales: todasLasRazas,
              alCambiarResultados: _actualizarResultados,
              opcionesFiltro: const [
                "A-Z",
                "Z-A",
                "Tamaño ↑",
                "Tamaño ↓",
                "Peso ↑",
                "Peso ↓",
              ],
            ),
            const SizedBox(height: 10),
            // Cargar las tarjetas de razas de perro
            GridView.builder(
              shrinkWrap: true,
              // Desactivar scroll del gridview
              physics: const NeverScrollableScrollPhysics(),
              // Como organizar las tarjetas
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                // Dos columnas
                crossAxisCount: 2,
                // Proporcion de las tarjetas
                childAspectRatio: 1.02,
                // Espacio horizontal entre tarjetas
                crossAxisSpacing: 16,
                // Espacio vertical entre tarjetas
                mainAxisSpacing: 35,
              ),
              // Numero de tarjetas a mostrar
              itemCount: listaRazasFiltradas.length,
              itemBuilder: (context, index) {
                // Obtener los datos de la raza actual
                final breed = listaRazasFiltradas[index];
                return TarjetaRazaStyle(
                  nombreRaza: breed['raza'] as String,
                  rutaImagen: breed['ico_imagen'] as String,
                  // Ir a la informacion de cada raza
                  onTap: () async {
                    // Verificar conexión antes de navegar
                    bool isConnected = await Seguridad.comprobarConexion();

                    if (!context.mounted) return;
                    
                    if (!isConnected) {
                      if (mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => NetworkErrorPage()),
                        );
                      }
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => PetWikiInformationPage(razaData: breed),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            // Indicador de carga
            if (_cargando || _cargandoMas)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      // Si el usuario esta conectado mostrar el boton flotante de las razas favoritas, si no no mostrar
      floatingActionButton:
          (userId != null && userId.isNotEmpty)
              ? FloatingActionButton(
                  onPressed: () async {
                    // Verificar conexión antes de navegar
                    bool isConnected = await Seguridad.comprobarConexion();

                    if (!context.mounted) return;

                    if (!isConnected) {
                      if (mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => NetworkErrorPage()),
                        );
                      }
                      return;
                    }
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const FavouriteBreedsPage(),
                      ),
                    );
                    setState(() {});
                  },
                backgroundColor: colorEspecial,
                elevation: 8,
                tooltip: 'Ver favoritos',
                child: const Icon(Icons.favorite, size: 28),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
