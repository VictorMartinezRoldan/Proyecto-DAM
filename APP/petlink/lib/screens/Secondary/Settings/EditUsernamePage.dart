import 'package:flutter/material.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditUsernamePage extends StatefulWidget {
  const EditUsernamePage({super.key});

  @override
  State<EditUsernamePage> createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  late final custom = Theme.of(context).extension<CustomColors>()!;
  late final tema = Theme.of(context).colorScheme;
  final _controladorUsuario = TextEditingController();
  bool _guardando = false;

  // Validacion de nombre de usuario
  String? validarNombreUsuario(String nombreUsuario) {
    if (nombreUsuario.contains(' ')) {
      return 'El nombre de usuario no puede contener espacios';
    }

    nombreUsuario = nombreUsuario.trim().toLowerCase();

    if (nombreUsuario.isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }

    if (nombreUsuario.length < 5) {
      return 'El nombre de usuario debe tener al menos 5 caracteres';
    }

    if (nombreUsuario.length > 20) {
      return 'El nombre de usuario no puede exceder 20 caracteres';
    }

    // Solo letras, numeros, puntos y guiones bajos
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(nombreUsuario)) {
      return 'Solo se permiten letras, números, puntos y guiones bajos';
    }

    // No puede comenzar o terminar con punto o guion bajo
    if (nombreUsuario.startsWith('.') ||
        nombreUsuario.startsWith('_') ||
        nombreUsuario.endsWith('.') ||
        nombreUsuario.endsWith('_')) {
      return 'No puede comenzar o terminar con punto o guión bajo';
    }

    // No permitir caracteres especiales consecutivos
    if (nombreUsuario.contains('..') ||
        nombreUsuario.contains('__') ||
        nombreUsuario.contains('._') ||
        nombreUsuario.contains('_.')) {
      return 'No se permiten caracteres especiales consecutivos';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _controladorUsuario.text = SupabaseAuthService.nombreUsuario;
  }

  @override
  void dispose() {
    _controladorUsuario.dispose();
    super.dispose();
  }

  // Metodo para actualizar el usuario
  Future<void> _actualizarUsuario() async {
  final nuevoUsuario = _controladorUsuario.text.trim();
  
  // Ejecutar todas las validaciones
  final errorValidacion = validarNombreUsuario(nuevoUsuario);
  if (errorValidacion != null) {
    MensajeSnackbar.mostrarError(context, errorValidacion);
    return;
  }

  setState(() => _guardando = true);

  try {
    final supabase = Supabase.instance.client;
    final idUsuario = SupabaseAuthService.id;
    final nombreActual = SupabaseAuthService.nombreUsuario;

    // Verificar si el nuevo nombre de usuario es igual al actual
    if (nuevoUsuario.toLowerCase() == nombreActual.toLowerCase()) {
      MensajeSnackbar.mostrarError(context, 'El nombre de usuario no ha cambiado');
      setState(() => _guardando = false);
      return;
    }

    // Verificar si el nuevo nombre de usuario ya existe
    final existe = await supabase
        .from('usuarios')
        .select('id')
        .eq('nombre_usuario', nuevoUsuario.toLowerCase())
        .maybeSingle();

    if (existe != null && existe['id'] != idUsuario) {
      if (!mounted) return;
      MensajeSnackbar.mostrarError(context, 'El nombre de usuario ya está en uso');
      return;
    }

    // Actualizar el nombre de usuario en la BD
    await supabase
        .from('usuarios')
        .update({'nombre_usuario': nuevoUsuario.toLowerCase()})
        .eq('id', idUsuario);

    await SupabaseAuthService().obtenerUsuario();
    if (!mounted) return;
    MensajeSnackbar.mostrarExito(context, 'Usuario actualizado');
  } catch (e) {
    MensajeSnackbar.mostrarError(context, 'Error: ${e.toString()}');
  } finally {
    if (mounted) setState(() => _guardando = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _construirEncabezado(),
                  const SizedBox(height: 32),
                  _construirCampoUsuario(),
                  const SizedBox(height: 32),
                  _construirBotonGuardar(),
                  const Spacer(),
                  _construirEnlaceInfo(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Encabezado de la página
  Widget _construirEncabezado() {
    return Column(
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 70,
          color: custom.colorEspecial.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.editUsernameTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.editUsernameTitleDesc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

// Campo de texto para el nombre de usuario
  Widget _construirCampoUsuario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editUsernameName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: custom.contenedor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: custom.sombraContenedor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controladorUsuario,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.pets),
              suffixIcon: IconButton(
                icon: _controladorUsuario.text.isNotEmpty
                    ? Icon(Icons.close_rounded, 
                        color: tema.onSurface.withValues(alpha: 0.4))
                    : const SizedBox.shrink(),
                onPressed: () {
                  setState(() {
                    _controladorUsuario.clear();
                  });
                },
              ),
              hintText: 'ej: amante_mascotas123',
              hintStyle: TextStyle(
                color: tema.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

/// Botón para guardar cambios.
  Widget _construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardando ? null : _actualizarUsuario,
        style: ElevatedButton.styleFrom(
          backgroundColor: custom.colorEspecial,
          foregroundColor: custom.contenedor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _guardando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.editUsernameSave,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

/// Enlace para mostrar información sobre los nombres de usuario
  Widget _construirEnlaceInfo() {
    return Center(
      child: TextButton(
        onPressed: _mostrarInfoUsuario,
        child: Text(
          AppLocalizations.of(context)!.editUsernameInfoTitle,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

/// Mostrar información sobre los nombres de usuario
  void _mostrarInfoUsuario() {
    final logo = "assets/logos/petlink_${(Provider.of<ThemeProvider>(context, listen: false).isLightMode) ? "black" : "grey"}.png";

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: custom.contenedor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: custom.contenedor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(logo, width: 80, height: 80),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.editUsernameInfoTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.editUsernameInfoBody,
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}