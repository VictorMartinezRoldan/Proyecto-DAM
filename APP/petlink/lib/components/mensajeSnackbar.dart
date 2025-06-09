import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class MensajeSnackbar {
  // Variable  para mantener la referencia del toast actual
  static OverlayEntry? _toastActual;
  // Variable para mantener la referencia del timer actual
  static Timer? _timerActual;
  static CustomColors? _customColors;

  // Método para inicializar los colores personalizados
  static void _inicializarColores(BuildContext context) {
    _customColors ??= Theme.of(context).extension<CustomColors>()!;
  }

  static void mostrarInfo(
    BuildContext context,
    String mensaje, {
    VoidCallback? alCerrar,
  }) {
    _inicializarColores(context);

    _mostrarToast(
      context,
      mensaje,
      icono: CupertinoIcons.info_circle,
      colorFondoIcono: const Color(0xFF4B84F4),
      colorIcono: Colors.white,
      colorTexto: _customColors!.contenedor,
      colorBoton: const Color(0xFF4B84F4),
      alCerrar: alCerrar,
    );
  }

  static void mostrarExito(
    BuildContext context,
    String mensaje, {
    VoidCallback? alCerrar,
  }) {
    _inicializarColores(context);

    _mostrarToast(
      context,
      mensaje,
      icono: CupertinoIcons.checkmark_circle,
      colorFondoIcono: Colors.green,
      colorIcono: Colors.white,
      colorTexto: _customColors!.sombraContenedor,
      colorBoton: Colors.green,
      alCerrar: alCerrar,
    );
  }

  static void mostrarError(
    BuildContext context,
    String mensaje, {
    VoidCallback? alCerrar,
  }) {
    _inicializarColores(context);

    _mostrarToast(
      context,
      mensaje,
      icono: CupertinoIcons.clear_circled,
      colorFondoIcono: Colors.red,
      colorIcono: Colors.white,
      colorTexto: _customColors!.contenedor,
      colorBoton: Colors.red,
      alCerrar: alCerrar,
    );
  }

  static void _mostrarToast(
    BuildContext context,
    String mensaje, {
    required IconData icono,
    required Color colorFondoIcono,
    required Color colorIcono,
    required Color colorTexto,
    required Color colorBoton,
    VoidCallback? alCerrar,
  }) {
    // Eliminar el toast anterior si existe
    _eliminarToastActual();

    final superposicion = Overlay.of(context);

    _toastActual = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: _WidgetToast(
              mensaje: mensaje,
              icono: icono,
              colorFondoIcono: colorFondoIcono,
              colorIcono: colorIcono,
              colorTexto: colorTexto,
              colorBoton: colorBoton,
              alCerrar: () {
                _eliminarToastActual();
                if (alCerrar != null) alCerrar();
              },
            ),
          ),
    );

    superposicion.insert(_toastActual!);

    // Codigo por si hay varios toast seguidos
    // Crear timer para el siguiente toast
    _timerActual = Timer(const Duration(seconds: 4), () {
      _eliminarToastActual();
    });
  }

  // Eliminar el toast actual y cancelar el timer
  static void _eliminarToastActual() {
    // Cancelar el timer anterior si existe
    if (_timerActual != null && _timerActual!.isActive) {
      _timerActual!.cancel();
    }
    _timerActual = null;

    // Eliminar el toast anterior si existe
    if (_toastActual != null && _toastActual!.mounted) {
      _toastActual!.remove();
    }
    _toastActual = null;
  }

  // Método para cerrar manualmente cualquier toast activo
  static void cerrarToast() {
    _eliminarToastActual();
  }
}

class _WidgetToast extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final Color colorFondoIcono;
  final Color colorIcono;
  final Color colorTexto;
  final Color colorBoton;
  final VoidCallback? alCerrar;

  const _WidgetToast({
    Key? clave,
    required this.mensaje,
    required this.icono,
    required this.colorFondoIcono,
    required this.colorIcono,
    required this.colorTexto,
    required this.colorBoton,
    this.alCerrar,
  }) : super(key: clave);

  @override
  Widget build(BuildContext context) {
    late var personalizado = Theme.of(context).extension<CustomColors>()!;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: personalizado.contenedor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF28292A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Franja vertical
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: colorFondoIcono,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Icono
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorFondoIcono.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icono, color: colorFondoIcono, size: 24),
                ),
              ),
              const SizedBox(width: 10),
              // Texto
              Expanded(
                child: Padding(
                  // Padding para el texto
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    mensaje,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: colorTexto,
                      height: 1.3,
                    ),
                    maxLines: null,
                    softWrap: true,
                  ),
                ),
              ),
              // Botón más compacto
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: colorBoton,
                splashRadius: 18,
                onPressed: alCerrar,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
