import 'package:flutter/material.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/components/providerIdioma.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguagePage extends StatefulWidget {
  const SelectLanguagePage({super.key});

  @override
  State<SelectLanguagePage> createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  late final custom = Theme.of(context).extension<CustomColors>()!;
  late final tema = Theme.of(context).colorScheme;

  // Variable para guardar el idioma seleccionado
  String _idiomaSeleccionado = 'es';

  // Mapa de idiomas con nombre y el emoji de bandera
  final Map<String, Map<String, dynamic>> _idiomas = {
    'es': {'nombre': 'Español', 'bandera': '🇪🇸'},   // ESPAÑOL
    'en': {'nombre': 'English', 'bandera': '🇬🇧'},   // INGLÉS
    'fr': {'nombre': 'Français', 'bandera': '🇫🇷'},  // FRANCÉS
    'zh': {'nombre': '中文', 'bandera': '🇨🇳'},      // CHINO
    'ja': {'nombre': '日本語', 'bandera': '🇯🇵'},     // JAPONÉS
    'it': {'nombre': 'Italiano', 'bandera': '🇮🇹'},  // ITALIANO
    'pt': {'nombre': 'Português', 'bandera': '🇧🇷'}, // PORTUGUÉS
    'de': {'nombre': 'Deutsch', 'bandera': '🇩🇪'},   // ALEMÁN
    'ru': {'nombre': 'Русский', 'bandera': '🇷🇺'},   // RUSO
    'hi': {'nombre': 'हिन्दी', 'bandera': '🇮🇳'},      // Hindi
    'ar': {'nombre': 'عربي', 'bandera': '🇸🇦'},     // Árabe (Arabia Saudita)
  };

  // Método para guardar el idioma seleccionado
  void _guardarIdioma() {
    // Guardar idioma seleccionado en provider
    final localeProvider = Provider.of<Provideridioma>(context, listen: false);
    localeProvider.establecerIdioma(Locale(_idiomaSeleccionado));

    // Obtener los datos del idioma seleccionado
    final idioma = _idiomas[_idiomaSeleccionado];
    final nombreIdioma = idioma?['nombre'] ?? _idiomaSeleccionado;
    final bandera = idioma?['bandera'] ?? '';

    MensajeSnackbar.mostrarExito(context, 'Idioma cambiado a: $nombreIdioma');
  }

  @override
  void initState() {
    super.initState();
    // Cargar el idioma guardado al iniciar la página
    // Inicializar con el idioma actual
    _idiomaSeleccionado = Provider.of<Provideridioma>(context, listen: false).locale.languageCode;
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
                  _construirSelectorIdioma(),
                  const SizedBox(height: 32),
                  _construirBotonGuardar(),
                  const SizedBox(height: 20),

                  // Boton para limpiar el idioma guardado (es para pruebas, se borrara mas adelante)
                  ElevatedButton(
                    onPressed: () async {
                      await Provider.of<Provideridioma>(
                        context,
                        listen: false,
                      ).limpiarIdiomaGuardado();
                    },
                    child: Text('Borrar idioma guardado (Debug)'),
                  ),
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
          Icons.language_rounded,
          size: 70,
          color: custom.colorEspecial.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.selectLanguageTitle,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.selectLanguageTitleDesc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _construirSelectorIdioma() {
    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _idiomaSeleccionado,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
        // Cargar los idiomas desde el mapa
        items:
            _idiomas.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Emoji de bandera alineado con el texto
                        SizedBox(
                          width: 29,
                          height: 24,
                          child: Center(
                            child: Text(
                              entry.value['bandera']!,
                              style: const TextStyle(
                                fontSize: 21,
                                height:
                                    1, // Ajusta la altura para centrar el emoji
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          entry.value['nombre']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _idiomaSeleccionado = value);
        },
      ),
    );
  }

  Widget _construirBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardarIdioma,
        style: ElevatedButton.styleFrom(
          backgroundColor: custom.colorEspecial,
          foregroundColor: custom.contenedor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.selectLanguageButtonSave,
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
