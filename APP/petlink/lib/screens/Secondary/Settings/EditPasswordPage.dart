import 'package:flutter/material.dart';
import 'package:petlink/components/indicadorFuerzaPassword.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  late final custom = Theme.of(context).extension<CustomColors>()!;
  late final tema = Theme.of(context).colorScheme;

  final _controladorPasswordActual = TextEditingController();
  final _controladorNuevoPassword = TextEditingController();
  final _controladorConfirmarPassword = TextEditingController();

  bool _guardando = false;
  bool _mostrarPasswordActual = false;
  bool _mostrarNuevoPassword = false;
  bool _mostrarConfirmarPassword = false;

  @override
  void dispose() {
    _controladorPasswordActual.dispose();
    _controladorNuevoPassword.dispose();
    _controladorConfirmarPassword.dispose();
    super.dispose();
  }

  Future<void> _cambiarPassword() async {
    if (_controladorPasswordActual.text.isEmpty ||
        _controladorNuevoPassword.text.isEmpty ||
        _controladorConfirmarPassword.text.isEmpty) {
      MensajeSnackbar.mostrarError(context, 'Todos los campos son obligatorios');
      return;
    }

    if (_controladorNuevoPassword.text != _controladorConfirmarPassword.text) {
      MensajeSnackbar.mostrarError(context, 'Las contraseñas no coinciden');
      return;
    }

    if (_controladorNuevoPassword.text.length < 6) {
      MensajeSnackbar.mostrarError(context, 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (_controladorPasswordActual.text == _controladorNuevoPassword.text) {
      MensajeSnackbar.mostrarError(context, 'La nueva contraseña debe ser diferente a la actual');
      return;
    }

    // Validacion de combinación de caracteres
    final nuevaPassword = _controladorNuevoPassword.text;
    final tieneMayuscula = nuevaPassword.contains(RegExp(r'[A-Z]'));
    final tieneMinuscula = nuevaPassword.contains(RegExp(r'[a-z]'));
    final tieneNumero = nuevaPassword.contains(RegExp(r'[0-9]'));
    final tieneSimbolo = nuevaPassword.contains(RegExp(r'[!@#$%^&*]'));
    
    // Verificar si se cumplen al menos 3 de los 4 criterios
    final criteriosCumplidos  = [tieneMayuscula, tieneMinuscula, tieneNumero, tieneSimbolo]
        .where((cumpleCriterio) => cumpleCriterio)
        .length;

    if (criteriosCumplidos  < 3) {
      MensajeSnackbar.mostrarError(context, 
          'La contraseña debe incluir al menos 3 de estas 4 categorías:\n'
          '- Una letra mayúscula\n'
          '- Una letra minúscula\n'
          '- Un número\n'
          '- Un símbolo (!@#\$%^&*)');
      return;
    }

    setState(() => _guardando = true);

    try {
      final supabase = Supabase.instance.client;
      
      await supabase.auth.signInWithPassword(
        email: SupabaseAuthService.correo,
        password: _controladorPasswordActual.text,
      );
      
      // Actualizar la contraseña
      await supabase.auth.updateUser(
        UserAttributes(password: _controladorNuevoPassword.text),
      );
      
      if (!mounted) return;
      MensajeSnackbar.mostrarExito(context, 'Contraseña actualizada correctamente');
      
      _controladorPasswordActual.clear();
      _controladorNuevoPassword.clear();
      _controladorConfirmarPassword.clear();

    } on AuthException catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error: ${e.message}');
    } catch (e) {
      MensajeSnackbar.mostrarError(context, 'Error al cambiar la contraseña');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
                  _construirCampoPasswordActual(),
                  const SizedBox(height: 16),
                  _construirCampoNuevoPassword(),
                  const SizedBox(height: 16),
                  _construirCampoConfirmarPassword(),
                  const SizedBox(height: 32),
                  _construirBotonGuardar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construirEncabezado() {
    return Column(
      children: [
        Icon(
          Icons.lock_outlined,
          size: 70,
          color: custom.colorEspecial.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.editPasswordTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.editPasswordTitleDesc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _construirCampoPasswordActual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editPasswordCurrentLabel,
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
            controller: _controladorPasswordActual,
            obscureText: !_mostrarPasswordActual,
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
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _mostrarPasswordActual 
                    ? Icons.visibility_off_rounded 
                    : Icons.visibility_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _mostrarPasswordActual = !_mostrarPasswordActual;
                  });
                },
              ),
              hintText: AppLocalizations.of(context)!.editPasswordCurrentHint,
              hintStyle: TextStyle(
                color: tema.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCampoNuevoPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editPasswordNewLabel,
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
            controller: _controladorNuevoPassword,
            obscureText: !_mostrarNuevoPassword,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _mostrarNuevoPassword 
                    ? Icons.visibility_off_rounded 
                    : Icons.visibility_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _mostrarNuevoPassword = !_mostrarNuevoPassword;
                  });
                },
              ),
              hintText: AppLocalizations.of(context)!.editPasswordNewHint,
              hintStyle: TextStyle(
                color: tema.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        IndicadorFuerzaPassword(
          password: _controladorNuevoPassword.text,
        ),
      ],
    );
  }

  Widget _construirCampoConfirmarPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editPasswordConfirmLabel,
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
            controller: _controladorConfirmarPassword,
            obscureText: !_mostrarConfirmarPassword,
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
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _mostrarConfirmarPassword 
                    ? Icons.visibility_off_rounded 
                    : Icons.visibility_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _mostrarConfirmarPassword = !_mostrarConfirmarPassword;
                  });
                },
              ),
              hintText: AppLocalizations.of(context)!.editPasswordConfirmHint,
              hintStyle: TextStyle(
                color: tema.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardando ? null : _cambiarPassword,
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
                AppLocalizations.of(context)!.editPasswordButtonSave,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}