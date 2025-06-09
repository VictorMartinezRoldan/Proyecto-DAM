import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:petlink/components/dialogoPregunta.dart';
import 'package:petlink/components/mensajeSnackbar.dart';
import 'package:petlink/screens/Secondary/EditProfilePage.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';
import 'package:petlink/screens/Secondary/RegisterPage.dart';
import 'package:petlink/screens/Secondary/SettingsPage.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:petlink/themes/themeProvider.dart';

class UserPage extends StatefulWidget {
  final String? idUsuario;
  const UserPage({super.key, this.idUsuario});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP

  final SupabaseAuthService authService = SupabaseAuthService();
  Map<String, dynamic>? datosUser;
  List<String> userPosts = [];
  bool esPerfilPropio = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SupabaseAuthService.isLogin.addListener(reconstruir);
    _inicializarPerfil();
  }

  @override
  void dispose() {
    _modoSeleccion = false;
    _publicacionesSeleccionadas.clear();
    SupabaseAuthService.isLogin.removeListener(reconstruir); // IMPORTANTE
    super.dispose();
  }

  void reconstruir() async {
    setState(() {
      // RECONSTRUIMOS
    });
  }

  // Inicializar perfil segun userId
  Future<void> _inicializarPerfil() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Si no hay userId, mostrar perfil del usuario logueado
      if (widget.idUsuario == null) {
        esPerfilPropio = true;
        if (SupabaseAuthService.isLogin.value) {

          // Forzar actualizacion de las publicaciones
          await authService.obtenerPublicaciones();

          datosUser = {
            'id': SupabaseAuthService.id,
            'nombre': SupabaseAuthService.nombre,
            'nombre_usuario': SupabaseAuthService.nombreUsuario,
            'descripcion': SupabaseAuthService.descripcion,
            'imagen_perfil': SupabaseAuthService.imagenPerfil,
            'imagen_portada': SupabaseAuthService.imagenPortada,
            'correo': SupabaseAuthService.correo,
          };
          userPosts = SupabaseAuthService.publicaciones;
        }
      } else {
        // Mostrar perfil de otro usuario
        esPerfilPropio = widget.idUsuario == SupabaseAuthService.id;
        datosUser = await authService.obtenerUsuarioPorId(widget.idUsuario!);
        if (datosUser != null) {
          userPosts = await authService.obtenerPublicacionesPorUsuario(
            widget.idUsuario!,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      MensajeSnackbar.mostrarError(context, 'Ocurrió un error al cargar el perfil');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _eliminarPublicacionesSeleccionadas() async {
    // Mostrar diálogo de confirmación usando tu widget reutilizable
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => DialogoPregunta(
            titulo: 'Confirmar eliminación',
            texto:'¿Estás seguro de que quieres eliminar ${_publicacionesSeleccionadas.length} publicación(es)? Esta acción no se puede deshacer.',
            textoBtn1: 'Cancelar',
            textoBtn2: 'Eliminar',
            ColorBtn1: custom.colorEspecial,
            ColorBtn2: Colors.red, // Color rojo para el botón de eliminar
          ),
    );

    // Si el usuario confirma, proceder con la eliminación
    if (confirmar == true) {
      await _ejecutarEliminacion();
    }
  }

  // Metodo para eliminar las publicaciones seleccionadas del perfil
  Future<void> _ejecutarEliminacion() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: CircularProgressIndicator(color: custom.colorEspecial),
          ),
    );

    try {
      // Obtener las urls de las publicaciones seleccionadas
      List<String> urlsAEliminar =
          _publicacionesSeleccionadas.map((index) => userPosts[index]).toList();

      // Llamada al metodo de eliminacion
      bool exito = await authService.eliminarPublicacionesSeleccionadas(
        urlsAEliminar,
      );

      // Cerrar el dialogo de carga
      if (!mounted) return;
      Navigator.of(context).pop();

      if (exito) {
        _actualizarUITrasEliminacion();
        MensajeSnackbar.mostrarExito(context,'Publicaciones eliminadas exitosamente',);
      } else {
        MensajeSnackbar.mostrarError(context, 'Error al eliminar las publicaciones');
      }
    } catch (e) {
      Navigator.of(context).pop();
      MensajeSnackbar.mostrarError(context, 'Error inesperado: $e');
    }
  }

  // Metodo para actualizar el widget al eliminar publicaciones
  void _actualizarUITrasEliminacion() {
    setState(() {
      // Eliminar los posts de la lista local en orden inverso para mantener indices
      List<int> indicesOrdenados =
          _publicacionesSeleccionadas.toList()..sort((a, b) => b.compareTo(a));
      for (int index in indicesOrdenados) {
        userPosts.removeAt(index);
      }

      _modoSeleccion = false;
      _publicacionesSeleccionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    custom = Theme.of(context).extension<CustomColors>()!;
    tema = Theme.of(context).colorScheme;

    // Solo mostrar pantalla de login si es perfil propio y no esta logueado
    if (!SupabaseAuthService.isLogin.value && widget.idUsuario == null) {
      return Scaffold(body: usuarioNoLogueado(context));
    }

    // Mostrar loading mientras carga los datos
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            esPerfilPropio
                ? "Mi Perfil"
                : datosUser != null
                ? "Perfil de ${datosUser!['nombre'] ?? 'Usuario'}"
                : "Cargando perfil...",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: custom.colorEspecial),
        ),
      );
    }
    // Si no se encontraron datos del usuario
    if (datosUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.profileTitle,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: tema.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Usuario no encontrado',
                style: TextStyle(
                  fontSize: 18,
                  color: tema.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esPerfilPropio
              ? "Mi Perfil"
              : "Perfil de ${datosUser!['nombre'] ?? 'Usuario'}",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // Mostrar configuracion solo para perfil propio
        actions:
            esPerfilPropio
                ? [
                  IconButton(
                    icon: Icon(LineAwesomeIcons.cog, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                      setState(() {
                      _modoSeleccion = false;
                      _publicacionesSeleccionadas.clear();
                    });
                    },
                  ),
                ]
                : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        datosUser!['imagen_portada'] ??
                            'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: tema.surface,
                      boxShadow: [
                        BoxShadow(
                          color: tema.surface.withValues(alpha: 1.0),
                          spreadRadius: 40,
                          blurRadius: 30,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: custom.colorEspecial,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: custom.contenedor,
                      radius: 60,
                      // Imagen de perfil
                      backgroundImage:
                          datosUser!['imagen_perfil'] != null
                              ? CachedNetworkImageProvider(
                                datosUser!['imagen_perfil'],
                              )
                              : null,
                      child:
                          datosUser!['imagen_perfil'] == null
                              ? Icon(
                                Icons.person,
                                size: 50,
                                color: custom.colorEspecial,
                              )
                              : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Mostrar informacion
            Text(
              datosUser!['nombre'] ?? 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 18, color: custom.colorEspecial),
                SizedBox(width: 8),
                Text(
                  datosUser!['nombre_usuario'] ??
                      'Nombre de usuario no disponible',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                datosUser!['descripcion'] ?? 'Descripción no disponible',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 15),
            // Mostrar boton editar perfil unicamente si es perfil propio
            if (esPerfilPropio) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                  setState(() {
                    _modoSeleccion = false;
                    _publicacionesSeleccionadas.clear();
                  });
                  if (result == true) {
                    _inicializarPerfil();
                  }
                },
                icon: Icon(Icons.edit, color: custom.colorEspecial),
                label: Text(
                  AppLocalizations.of(context)!.editProfile,
                  style: TextStyle(color: custom.colorEspecial),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: custom.colorEspecial, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: _buildPostGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // Variable para el modo de seleccion
  bool _modoSeleccion = false;
  // Lista de las publicaciones seleccionadas a borrar
  final Set<int> _publicacionesSeleccionadas = {};
  
  // Widget para las publicaciones
  Widget _buildPostGrid() {
    // Si no tiene publicaciones se muestra mensaje
    if (userPosts.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noPublication));
    }

    return Column(
    children: [
      // Mostrar header con diferentes opciones segun este logueado o no
      Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  esPerfilPropio && _modoSeleccion
                      ? 'Seleccionar publicaciones'
                      : AppLocalizations.of(context)!.recentPosts,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (esPerfilPropio && _modoSeleccion)
                  Text(
                    '${_publicacionesSeleccionadas.length} de ${userPosts.length} seleccionados',
                    style: TextStyle(
                      fontSize: 12,
                      color: tema.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            // Solo mostrar botones de accion para perfil propio
            if (esPerfilPropio)
              _modoSeleccion
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: _publicacionesSeleccionadas.isNotEmpty
                              ? _eliminarPublicacionesSeleccionadas
                              : null,
                          icon: Icon(
                            Icons.delete,
                            color: _publicacionesSeleccionadas.isNotEmpty
                                ? Colors.red
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _modoSeleccion = false;
                              _publicacionesSeleccionadas.clear();
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: custom.colorEspecial,
                            size: 24,
                          ),
                        ),
                      ],
                    )
                  : IconButton(
                    // Activar el modo seleccion
                      onPressed: () {
                        setState(() {
                          _modoSeleccion = true;
                        });
                      },
                      icon: Icon(
                        MingCute.delete_2_line,
                        color: custom.colorEspecial,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            // Cuadricula de imagenes
            GridView.builder(
              // Ocupar solo el espacio necesario
              shrinkWrap: true,
              // Desactivar scroll interno
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // Columnas cuadricula
                crossAxisCount: 3,
                // Espacio horizontal entre imagenes
                crossAxisSpacing: 4,
                // Espacio vertical entre imagenes
                mainAxisSpacing: 4,
              ),
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                bool seleccionado = _publicacionesSeleccionadas.contains(index);
                return GestureDetector(
                  onTap:
                      _modoSeleccion
                          ? () {
                            setState(() {
                              if (seleccionado) {
                                _publicacionesSeleccionadas.remove(index);
                              } else {
                                _publicacionesSeleccionadas.add(index);
                              }
                            });
                          }
                          : () async {
                            // Navegar a publicación
                          },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Imagenes de las publicaciones
                            Image(
                              image: CachedNetworkImageProvider(userPosts[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Diseño para la imagene seleccionada
                            if (_modoSeleccion)
                              Container(
                                color:
                                    seleccionado
                                        ? Color.fromRGBO(0, 96, 255, 1).withValues(alpha: 0.35)
                                        : custom.bordeContenedor.withValues(alpha: 0.2),
                              ),
                            // Marca de seleccion de imagen
                            if (_modoSeleccion)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color:
                                        seleccionado
                                            ? Color.fromRGBO(0, 96, 255, 1)
                                            : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: custom.colorEspecial,
                                      width: 1.5,
                                    ),
                                  ),
                                  child:
                                      seleccionado
                                          ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          )
                                          : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }
          
  // Widget para mostrar informacion cuando el usuario no esta logueado
  Widget usuarioNoLogueado(BuildContext context) {
    final custom = Theme.of(context).extension<CustomColors>()!;
    final tema = Theme.of(context).colorScheme;
    final logo =
        "assets/logos/petlink_${(Provider.of<ThemeProvider>(context).isLightMode) ? "black" : "grey"}.png";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen o logo decorativo
            Image.asset(logo, height: 100, fit: BoxFit.contain),
            SizedBox(height: 24),
            Text(
              '¡Bienvenid@ a PetLink!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: tema.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Para ver tu perfil y tus publicaciones, inicia sesión en tu cuenta.',
              style: TextStyle(
                fontSize: 16,
                color: tema.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                icon: Icon(Icons.login, color: tema.onPrimary),
                label: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tema.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: custom.colorEspecial,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                icon: Icon(Icons.person_add, color: custom.colorEspecial),
                label: Text(
                  'Crear cuenta nueva',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: custom.colorEspecial,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: custom.contenedor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: custom.colorEspecial, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
