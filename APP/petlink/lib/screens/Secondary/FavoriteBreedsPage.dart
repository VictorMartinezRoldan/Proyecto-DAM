import 'package:flutter/material.dart';
import 'package:petlink/components/dialogoPregunta.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavouriteBreedsPage extends StatefulWidget {
  const FavouriteBreedsPage({super.key});

  @override
  State<FavouriteBreedsPage> createState() => _FavouriteBreedsPageState();
}

class _FavouriteBreedsPageState extends State<FavouriteBreedsPage> {

  late final SupabaseClient supabase = Supabase.instance.client;
  late final SupabaseAuthService authService = SupabaseAuthService();

  List<Map<String, String>> razasFavoritas = [];
  bool cargando = true;

  User? get _currentUser => supabase.auth.currentUser;
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM

  @override
  void initState() {
    super.initState();
    // Cargar las razas favoritas al iniciar la pagina
    cargarRazasFavoritas();
  }

  // Metodo para cargar las razas favoritas del usuario conectado
  Future<void> cargarRazasFavoritas() async {
    setState(() => cargando = true);

    // Verificar si el usuario esta conectado
    try {
      final user = _currentUser;
      if (user == null) {
        setState(() {
          razasFavoritas = [];
          cargando = false;
        });
        return;
      }

      // Consulta a la BD para obtener las razas
      final response = await supabase
          .from('raza_favorito')
          .select('raza, perros(ico_imagen)')
          .eq('id_usuario', user.id);

      // Actualizar el estado y crear la lista de razas favoritas
      setState(() {
        razasFavoritas =
            response
                .map<Map<String, String>>(
                  (item) => {
                    'nombre': item['raza'] as String,
                    'imagen': item['perros']['ico_imagen'] as String? ?? '',
                  },
                )
                .toList();
        
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
       if (!mounted) return;
      MensajeSnackbar.mostrarError(context, 'Error al cargar favoritos');
    }
  }

  // Metodo para eliminar una raza de favoritos
  Future<void> eliminarFavorito(String nombreRaza) async {
    final userId = _currentUser?.id;
    if (userId == null) return;

    // Delete de la raza favorita en la BD
    try {
      await supabase
          .from('raza_favorito')
          .delete()
          .eq('id_usuario', userId)
          .eq('raza', nombreRaza);

      // Actualizar el estado para eliminar la raza de la lista
      setState(
        () => razasFavoritas.removeWhere((b) => b['nombre'] == nombreRaza),
      );
       if (!mounted) return;
      MensajeSnackbar.mostrarInfo(context,'$nombreRaza se ha eliminado de favoritos');
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al eliminar de favoritos');
    }
  }

  // Mostrar un dialogo de confirmacion para eliminar una raza
  // Reutilizacion del componente DialogoPregunta
  void _dialogoEliminarRaza(String nombreRaza) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => DialogoPregunta(
            titulo: "Eliminar favorito",
            texto: "¿Estás seguro de que quieres eliminar $nombreRaza de tus favoritos?",
            textoBtn1: "Cancelar",
            textoBtn2: "Eliminar",
            ColorBtn1: custom.colorEspecial,
            ColorBtn2: Colors.redAccent,
          ),
    );
    // Si confirmamos es = true y se elimina
    if (confirmed == true) {
      eliminarFavorito(nombreRaza);
    }
  }

  // Widget para construir el cuerpo de la pagina
  Widget _construirCuerpo() {
    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (custom.colorEspecial.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (custom.colorEspecial.withValues(alpha: 0.08)),
        ),
      ),
      // Semi header con icono y titulo
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (custom.colorEspecial.withValues(alpha: 0.1)),
                ),
              ),
              Icon(Icons.favorite, color: custom.colorEspecial, size: 20),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: (custom.colorEspecial.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Mis Favoritas",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${razasFavoritas.length} ${razasFavoritas.length == 1 ? 'favorita' : 'favoritas'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: custom.bordeContenedor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir el estado cuando el usuario no tiene favoritos
  Widget _construirEstadoVacio() {
    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    // Si no hay razas favoritas mostrar un texto y un boton para volver a explorar las razas
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tema.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            // Icono corazon vacio
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: tema.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "No tienes favoritos aún",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            "Explora las razas en la wiki y\nagrega tus favoritas",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: custom.bordeContenedor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Boton para volver a explorar razas
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.explore,
              size: 20,
              ),
            label: const Text("Explorar Razas"),
            style: ElevatedButton.styleFrom(
              backgroundColor: custom.colorEspecial,
              foregroundColor: custom.contenedor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la tarjeta de cada raza favorita
  Widget _construirTarjetaFavorita(Map<String, String> raza) {

    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    // Variables para el degradado lineal (cambiados para color claro y oscuro)
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;
    final Color startColor = custom.contenedor;
    final Color endColor =
        esOscuro
            ? Color.lerp(custom.contenedor, tema.surface, 0.2)!
            : Colors.grey[100]!;

    // Tarjeta de raza favorita
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 6, right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: custom.sombraContenedor,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: custom.colorEspecial.withValues(alpha: 0.1),
            highlightColor: custom.colorEspecial.withValues(alpha: 0.05),
            child: Ink(
              padding: const EdgeInsets.all(16),
              // Gradient para dar un efecto distinto a la tarjeta
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  // Stops para ajustar la posicion del degradado
                  stops: [0.75, 0.75],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Imagen del perro
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: custom.colorEspecial.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: custom.colorEspecial.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: custom.sombraContenedor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CachedNetworkImage(
                        imageUrl: raza['imagen']!,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(
                              color: custom.colorEspecial.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.pets,
                                color: custom.colorEspecial.withValues(
                                  alpha: 0.5,
                                ),
                                size: 28,
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: tema.errorContainer.withValues(alpha: 0.3),
                              child: Icon(
                                Icons.pets,
                                color: tema.onErrorContainer.withValues(
                                  alpha: 0.7,
                                ),
                                size: 28,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informacion
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          raza['nombre']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: custom.colorEspecial.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Raza favorita",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: custom.colorEspecial,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón eliminar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _dialogoEliminarRaza(raza['nombre']!),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.heart_broken,
                          color: Colors.red.shade600,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;

    // Construir la pagina de favoritos
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Razas Favoritas",
          style: TextStyle(
            color: custom.colorEspecial,
            fontWeight: FontWeight.bold
            ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          cargando
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: custom.colorEspecial),
                    const SizedBox(height: 16),
                    Text(
                      "Cargando favoritos...",
                      style: TextStyle(
                        fontSize: 16,
                        color: tema.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
              : razasFavoritas.isEmpty
              ? _construirEstadoVacio()
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.5),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _construirCuerpo(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: razasFavoritas.length,
                        itemBuilder:
                            (_, i) =>
                                _construirTarjetaFavorita(razasFavoritas[i]),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
