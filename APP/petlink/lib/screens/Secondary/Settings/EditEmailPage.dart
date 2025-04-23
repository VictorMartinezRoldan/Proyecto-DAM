import 'package:flutter/material.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditEmailPage extends StatefulWidget {
  const EditEmailPage({super.key});

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  late final custom = Theme.of(context).extension<CustomColors>()!;
  late final tema = Theme.of(context).colorScheme;
  final _controladorEmailActual = TextEditingController();
  final _controladorNuevoEmail = TextEditingController();
  final _controladorConfirmarEmail = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _controladorEmailActual.text = SupabaseAuthService.correo;
  }

  @override
  void dispose() {
    _controladorEmailActual.dispose();
    _controladorNuevoEmail.dispose();
    _controladorConfirmarEmail.dispose();
    super.dispose();
  }

  Future<void> _actualizarEmail() async {
    final emailActual = _controladorEmailActual.text.trim();
    final nuevoEmail = _controladorNuevoEmail.text.trim();
    final confirmarEmail = _controladorConfirmarEmail.text.trim();

    // Validaciones
    if (nuevoEmail.isEmpty || confirmarEmail.isEmpty) {
      MensajeSnackbar.mostrarError(
        context,
        'Todos los campos son obligatorios',
      );
      return;
    }

    // Validar formato de correo electrónico
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(nuevoEmail)) {
      MensajeSnackbar.mostrarError(
        context,
        'Ingresa un correo electrónico válido',
      );
      return;
    }

    if (nuevoEmail != confirmarEmail) {
      MensajeSnackbar.mostrarError(context, 'Los correos nuevos no coinciden');
      return;
    }

    if (nuevoEmail == emailActual) {
      MensajeSnackbar.mostrarError(
        context,
        'El nuevo correo no puede ser igual al actual',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final supabase = Supabase.instance.client;

      // Verificar si el email ya existe en la tabla usuarios
      final existe =
          await supabase
              .from('usuarios')
              .select('id')
              .eq('correo', nuevoEmail)
              .maybeSingle();

      if (existe != null) {
        MensajeSnackbar.mostrarError(
          context,
          'El correo electrónico ya está registrado',
        );
        return;
      }

      final UserResponse res = await supabase.auth.updateUser(
        UserAttributes(email: nuevoEmail),
      );
      final User? updatedUser = res.user;
      if (updatedUser?.email == nuevoEmail) {
        MensajeSnackbar.mostrarExito(
          context,
          'Correo electrónico actualizado exitosamente',
        );
      } else {
        MensajeSnackbar.mostrarExito(
          context,
          'Se ha enviado un correo de confirmación a $nuevoEmail. Por favor, verifica tu nuevo correo.',
        );
      }

      // Actualizar el estado local
      await SupabaseAuthService().obtenerUsuario();

      MensajeSnackbar.mostrarExito(context, 'Correo electrónico actualizado');
      if (mounted) Navigator.pop(context);
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
                  _construirCampoEmailActual(),
                  const SizedBox(height: 16),
                  _construirCampoNuevoEmail(),
                  const SizedBox(height: 16),
                  _construirCampoConfirmarEmail(),
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
          Icons.email_outlined,
          size: 70,
          color: custom.colorEspecial?.withOpacity(0.8),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.editEmailTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.editEmailTitleDesc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _construirCampoEmailActual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editEmailCurrentLabel,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            controller: _controladorEmailActual,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.email_rounded),
              hintStyle: TextStyle(
                color: tema.onBackground.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCampoNuevoEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editEmailNewLabel,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            controller: _controladorNuevoEmail,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              hintText: AppLocalizations.of(context)!.editEmailNewHint,
              hintStyle: TextStyle(
                color: tema.onBackground.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCampoConfirmarEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.editEmailConfirmLabel,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            controller: _controladorConfirmarEmail,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              hintText: AppLocalizations.of(context)!.editEmailConfirmHint,
              hintStyle: TextStyle(
                color: tema.onBackground.withValues(alpha: 0.4),
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
        onPressed: _guardando ? null : _actualizarEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: custom.colorEspecial,
          foregroundColor: custom.contenedor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _guardando
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  AppLocalizations.of(context)!.editEmailButtonSave,
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
