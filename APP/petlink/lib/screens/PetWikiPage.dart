import 'package:flutter/material.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/components/tarjetaRazaStyle.dart';
import 'package:petlink/screens/Secondary/FavoriteBreedsPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/services/supabase_auth.dart';

class PetWikiPage extends StatefulWidget {
  const PetWikiPage({super.key});

  @override
  State<PetWikiPage> createState() => _PetWikiPageState();
}

class _PetWikiPageState extends State<PetWikiPage> {
  // Lista para guardar las razas obtenidas de la BD
  List<Map<String, String>> listaRazas = [];

  final userId = SupabaseAuthService.id;

  // Metodo para cargar las razas desde la BD
  Future<void> _cargarRazas() async {
    try {
      final respuesta = await Supabase.instance.client
          .from('perros')
          .select('raza, ico_imagen')
          .order('raza', ascending: true);

      // Actualizar el estado con las razas obtenidas
      setState(() {
        listaRazas =
            respuesta.map((item) {
              return {
                'nombre': item['raza'] as String,
                'imagen': item['ico_imagen'] as String,
              };
            }).toList();
      });
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al cargar las razas: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarRazas();
  }

  // Encabezado de la pagina
  Widget _headerAnimado(Color colorEspecial, Color primary) {
    final color = colorEspecial;
    return Column(
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
                color: color.withOpacity(0.4),
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
          children: [
            const SizedBox(height: 5),
            _headerAnimado(custom.colorEspecial, custom.contenedor),
            const SizedBox(height: 20),
            // Cargar las tarjetas de razas de perro
            GridView.builder(
              // Ocupar solo espacio necesario
              shrinkWrap: true,
              // Evitar que el gridview tenga un propio scroll
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                // Dos columnas de tarjetas
                crossAxisCount: 2,
                // Relacion de aspecto de las tarjetas
                childAspectRatio: 1.02,
                // Espacio entre tarjetas horizontalmente
                crossAxisSpacing: 16,
                // Espacio entre tarjetas verticalmente
                mainAxisSpacing: 35,
              ),
              // Numero de tarjetas
              itemCount: listaRazas.length,
              itemBuilder: (context, index) {
                final breed = listaRazas[index];
                return TarjetaRazaStyle(
                  nombreRaza: breed['nombre']!,
                  rutaImagen: breed['imagen']!,
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),

      // Si el usuario esta conectado mostrar el boton flotante de las razas favoritas, si no no mostrar
      floatingActionButton:
          (userId != null && userId.isNotEmpty)
              ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavouriteBreedsPage(),
                    ),
                  );
                  // Refresca la pagina al volver de favoritos
                  setState(() {});
                },
                backgroundColor: colorEspecial,
                elevation: 8,
                child: const Icon(Icons.favorite, size: 28),
                tooltip: 'Ver favoritos',
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
