import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:petlink/themes/customColors.dart';

class BuscadorRazas extends StatefulWidget {
  // Callback para comunicar cambios al widget padre
  final Function(List<Map<String, dynamic>>) alCambiarResultados;
  // Datos de las razas
  final List<Map<String, dynamic>> datosOriginales;
  // Lista de opciones
  final List<String> opcionesFiltro;
  final String textoSugerencia;
  
  const BuscadorRazas({
    super.key,
    required this.alCambiarResultados,
    required this.datosOriginales,
    this.opcionesFiltro = const [],
    this.textoSugerencia = "Buscar...",
  });

  @override
  State<BuscadorRazas> createState() => _BuscadorRazasState();
}

class _BuscadorRazasState extends State<BuscadorRazas> {
  final _controladorBusqueda = TextEditingController();
  String _busquedaActual = "";
  String? _filtroSeleccionado;

  @override
  void initState() {
    super.initState();
    // Listener para cuando el texto del buscador cambia
    _controladorBusqueda.addListener(() {
      if (_controladorBusqueda.text != _busquedaActual) {
        _busquedaActual = _controladorBusqueda.text;
        // Ejecutar el filtro en tiempo real
        _aplicarFiltros();
      }
    });
  }

  // Liberar recursos
  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  // Convertir la cadena de textos que contiene rangos de numeros
  double _extraerNumero(String? texto, bool esMaximo) {
    // Si el texto es nulo devolver 0
    if (texto == null || texto.isEmpty) return 0.0;
    
    final limpio = texto.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
    final patron = esMaximo ? RegExp(r'-\s*(\d+(?:[.,]\d+)?)') : RegExp(r'^(\d+(?:[.,]\d+)?)');
    final match = patron.firstMatch(limpio);
    
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
    }
    // Si contiene valor obtener el maximo
    return esMaximo ? _extraerNumero(texto, false) : 0.0;
  }

  // Calcular el valor promedio de un rango de numeros en string
  double _calcularPromedio(String? rango) {
    if (rango == null || rango.isEmpty) return 0.0;
    final min = _extraerNumero(rango, false);
    final max = _extraerNumero(rango, true);
    return (min + max) / 2;
  }

  // Obtener el tamaño promedio de todas las razas para poder comparar
  double _obtenerTamanoPromedio(Map<String, dynamic> raza) {
    final tamanoMacho = _calcularPromedio(raza['tamaño_macho']);
    final tamanoHembra = _calcularPromedio(raza['tamaño_hembra']);
    
    if (tamanoMacho > 0 && tamanoHembra > 0) return (tamanoMacho + tamanoHembra) / 2;
    return tamanoMacho > 0 ? tamanoMacho : tamanoHembra;
  }

  // Aplicar filtros para buscar raza y ordenar en tiempo real
  void _aplicarFiltros() {
    var resultados = widget.datosOriginales;

    // Aplicar búsqueda por texto
    if (_busquedaActual.isNotEmpty) {
      resultados = resultados.where((raza) =>
        raza['raza'].toString().toLowerCase().contains(_busquedaActual.toLowerCase())
      ).toList();
    }

    // Ordenar las razas en funcion de los filtros aplicados
    if (_filtroSeleccionado != null) {
      switch (_filtroSeleccionado) {
        case "A-Z": 
        // Ordenar alfabeticamente ascendente por el nombre de la raza del perro
          resultados.sort((a, b) => a['raza'].toString().compareTo(b['raza'].toString()));
        case "Z-A": 
        // Ordenar alfabeticamente descentente por el nombre de la raza del perro
          resultados.sort((a, b) => b['raza'].toString().compareTo(a['raza'].toString()));
        case "Tamaño ↑": 
        // Ordenar por tamaño ascendente
          resultados.sort((a, b) => _obtenerTamanoPromedio(a).compareTo(_obtenerTamanoPromedio(b)));
        case "Tamaño ↓": 
        // Ordenar por tamaño descentente
          resultados.sort((a, b) => _obtenerTamanoPromedio(b).compareTo(_obtenerTamanoPromedio(a)));
        case "Peso ↑": 
        // Ordenar por peso ascendente
          resultados.sort((a, b) => _calcularPromedio(a['peso']).compareTo(_calcularPromedio(b['peso'])));
        case "Peso ↓": 
        // Ordenar por peso descendente
          resultados.sort((a, b) => _calcularPromedio(b['peso']).compareTo(_calcularPromedio(a['peso'])));
      }
    }

    widget.alCambiarResultados(resultados);
  }

  // Widget campo de texto
  Widget _construirTextField(CustomColors custom, ColorScheme tema) {
    
    return Expanded(
      // Ocupa el 75% de la pantalla
      flex: 3,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: custom.contenedor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: custom.sombraContenedor,
          ),
          boxShadow: [
            BoxShadow(
              color: custom.sombraContenedor.withValues(alpha:0.3),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          // Controlador para gestionar el texto
          controller: _controladorBusqueda,
          // Boton buscar en teclado
          textInputAction: TextInputAction.search,
          // Perder el foco al tocar fuera del textfield
          onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
          },
          // Placeholder
          decoration: InputDecoration(
            hintText: widget.textoSugerencia,
            hintStyle: TextStyle(
              color: tema.onSurface.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            // Icono de lupa
            prefixIcon: Icon(
              MingCute.search_3_line,
              color: custom.colorEspecial,
              size: 22,
            ),
            // Boton para limpiar cuando hay texto
            suffixIcon: _busquedaActual.isNotEmpty ? IconButton(
              icon: Icon(
                Icons.clear,
                size: 20,
              ),
              onPressed: () {
                // Limpiar el texto y resetear la busqueda
                _controladorBusqueda.clear();
                _busquedaActual = "";
                _aplicarFiltros();
              },
            ) : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  IconData _obtenerIconoFiltro(String filtro) => switch (filtro) {
    "A-Z" => MingCute.AZ_sort_ascending_letters_line,
    "Z-A" => MingCute.AZ_sort_descending_letters_line,
    "Tamaño ↑" => MingCute.minimize_line,
    "Tamaño ↓" => MingCute.add_line,
    "Peso ↑" => MingCute.barbell_line,
    "Peso ↓" => MingCute.barbell_line,
    _ => Icons.sort,
  };

  Widget _construirFiltroMenu(CustomColors custom, ColorScheme tema) {
    // Validar si hay filtros disponibles
    if (widget.opcionesFiltro.isEmpty) return SizedBox.shrink();
    return Expanded(
      // Ocupar el 25% del espacio disponible
      flex: 1,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: custom.contenedor,
          borderRadius: BorderRadius.circular(15),
          // Borde que cambia de color dependiendo de si hay un filtro seleccionado
          border: Border.all(
            color: _filtroSeleccionado != null 
              ? custom.colorEspecial.withValues(alpha: 0.5)
              : custom.colorEspecial.withValues(alpha: 0.3),
            width: _filtroSeleccionado != null ? 1.2 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: custom.sombraContenedor.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Menu desplegable de filtros
        child: PopupMenuButton<String>(
          // Seccion redondeada
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: custom.contenedor,
          surfaceTintColor: Colors.transparent,
          // Si se aplica el mismo filtro se desactiva
          onSelected: (valor) {
            setState(() => _filtroSeleccionado = _filtroSeleccionado == valor ? null : valor);
            // Aplicar filtro con el nuevo estado
            _aplicarFiltros();
          },
          // Construir los elementos del menu
          itemBuilder: (context) => widget.opcionesFiltro.map((opcion) => PopupMenuItem<String>(
            value: opcion,
            child: Row(
              children: [
                // Iconos para cada filtro
                Icon(
                  _obtenerIconoFiltro(opcion), 
                  size: 18, 
                  color: _filtroSeleccionado == opcion 
                    ? custom.colorEspecial 
                    : tema.onSurface.withValues(alpha: 0.7),
                ),
                SizedBox(width: 8),
                // Texto del filtro
                Text(
                  opcion, 
                  style: TextStyle(
                    color: _filtroSeleccionado == opcion 
                      ? custom.colorEspecial 
                      : tema.onSurface,
                    fontWeight: _filtroSeleccionado == opcion ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )).toList(),
          // Boton principal para abrir el menu
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MingCute.filter_2_line, 
                  color: _filtroSeleccionado != null 
                    ? custom.colorEspecial 
                    : custom.textoSuave, 
                  size: 20,
                ),
                SizedBox(width: 4),
                // Indicador cuando hay un filtro activo
                if (_filtroSeleccionado != null)
                  Container(
                    width: 8, 
                    height: 8, 
                    decoration: BoxDecoration(
                      color: custom.colorEspecial, 
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 2.5),
      child: Row(
        children: [
          _construirTextField(custom, tema),
          _construirFiltroMenu(custom, tema),
        ],
      ),
    );
  }
}
