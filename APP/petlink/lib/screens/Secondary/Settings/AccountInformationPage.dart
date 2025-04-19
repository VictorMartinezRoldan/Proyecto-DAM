import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/Settings/EditEmailPage.dart';
import 'package:petlink/screens/Secondary/Settings/EditPasswordPage.dart';
import 'package:petlink/screens/Secondary/Settings/EditUsernamePage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/services/supabase_auth.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  late final custom = Theme.of(context).extension<CustomColors>()!;
  late final tema = Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirEncabezado(),
              const SizedBox(height: 5),
              _construirTarjetasInformacion(),
            ],
          ),
        );
      },
    );
  }

  Widget _construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              // Decoracion izquierda
              Container(
                height: 3,
                width: 30,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: custom.colorEspecial,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Texto principal
              Text(
                'Información de la cuenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Decoracion derecha
              Container(
                height: 3,
                width: 30,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: custom.colorEspecial,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Texto secundario
          Text(
            'Gestiona los detalles de tu cuenta',
            style: TextStyle(
              fontSize: 14,
              color: tema.onSurface.withValues(alpha: 0.6),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Linea decorativa inferior
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              color: custom.colorEspecial.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetasInformacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirTarjetaOpcion(
            icon: LineAwesomeIcons.user,
            titulo: 'Nombre de usuario',
            subtitulo: SupabaseAuthService.nombreUsuario,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditUsernamePage()),
            ),
            iconColor: custom.colorEspecial,
          ),
          const SizedBox(height: 16),
          _construirTarjetaOpcion(
            icon: LineAwesomeIcons.envelope,
            titulo: 'Correo electrónico',
            subtitulo: SupabaseAuthService.correo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditEmailPage()),
            ),
            iconColor: custom.colorEspecial,
          ),
          const SizedBox(height: 16),
          _construirTarjetaOpcion(
            icon: LineAwesomeIcons.lock,
            titulo: 'Contraseña',
            subtitulo: '••••••••',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditPasswordPage()),
            ),
            iconColor: custom.colorEspecial,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaOpcion({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: custom.contenedor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: custom.sombraContenedor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: iconColor.withValues(alpha: 0.1),
          highlightColor: iconColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}