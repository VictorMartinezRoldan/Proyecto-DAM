// BIBLIOTECAS
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petlink/components/menuLateral.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// CLASES
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/components/publicacionStyle.dart';
import 'package:petlink/entidades/comentario.dart';
import 'package:petlink/components/comentarioStyle.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/Secondary/AuthController.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/themes/themeProvider.dart';

class ComentariosPage extends StatefulWidget {
  final Publicacion publicacion;
  const ComentariosPage({super.key, required this.publicacion});

  static FocusScopeNode focusScopeError = FocusScopeNode(); // Rama historial focusScope

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> with SingleTickerProviderStateMixin {

  // ATRIBUTOS

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); // Para control endDrawer

  FocusNode focusEscribir = FocusNode();

  TextEditingController controladorComentario = TextEditingController();

  bool consultando = false; // Ocultar animación de carga o mostrarla

  int indiceComentarios = 0; // Desde donde empieza, esto va cambiando

  List<ComentarioStyle> comentarios = []; // Lista que guarda los comentarios con estilo

  bool respondiendo = false; // Para saber si estoy respondiendo para mostrar _hintText o "Escribe tu comentario aquí"

  String _hintText = "";
  
  // MÉTODOS

  // Método para reiniciar el focusScope y quitar el focus actual
  void reiniciarFocus() {
    FocusScope.of(context).unfocus();
    ComentariosPage.focusScopeError = FocusScopeNode();
  }

  // Método que se ejecuta en el botón "Responder" de comentarioStyle
  void onResponder(String usuario) {
    setState(() {
      respondiendo = true;
      _hintText = "Dile algo a $usuario...";
    });
    focusEscribir.requestFocus();
  }

  void onEliminar(ComentarioStyle comentario) async {
    setState(() {
      comentarios.remove(comentario);
      widget.publicacion.numComentarios--;
    });
    await Comentario.eliminarComentario(context, comentario.comentario.idComentario);
  }

  // MÉTODO QUE LLAMA AL MÉTODO DE COMENTARIOS PARA SOLICITAR COMENTARIOS Y LAS AÑADE A LA LISTA DEL LISTVIEW
  Future<void> solicitarComentarios() async {

    print("NUEVA SOLICITUD");

    consultando = true;

    final int numeroComentarios = 2; // NÚMERO DE COMENTARIOS A CONSULTAR

    // Si hay comentarios y si el número de comentarios de la publicación es mayor al número existente de comentarios cargados...
    if (widget.publicacion.numComentarios > 0 && widget.publicacion.numComentarios > comentarios.length) {
      final response = await Comentario.solicitarComentarios(
        context,                // CONTEXTO PARA PROBLEMAS DE CONEXIÓN
        widget.publicacion.id,  // ID DE LA PUBLICACIÓN A CONSULTAR
        indiceComentarios,      // ÍNDICE DE LOS COMENTARIOS
        numeroComentarios       // NÚMERO DE COMENTARIOS A CONSULTAR
      ); 

      List<Comentario> newComentarios = [];

      // Recorro las respuestas
      for (int i = 0; i < response.length; i++) {
        var datos = response[i]; // EXTRAIGO LA INFORMACIÓN
        // CREO EL OBJETO
        Comentario newComentario = Comentario(
          idComentario: datos["id_comentario"], 
          imagenPerfil: datos["imagen_perfil"], 
          nombre: datos["nombre"],
          usuario: datos["usuario"],
          texto: datos["texto"],
          fecha: datos["fecha_comentario"],
          numRespuestas: 0, // CAMBIAR
          likes: datos["likes"], 
          liked: datos["liked"]
        );
        
        newComentarios.add(newComentario);

        int nuevoNumComentarios = datos["num_comentarios"];
        widget.publicacion.likes = datos["likes_publicacion"];

        // Aquí se a establecido una lógica especial, si encontramos un incremento de los comentarios calculo la diferencia,
        // esa diferencia es la cantidad de nuevos comentarios, lo que hace es solicitar esos nuevos comentarios, recoger los datos
        // y añadirlos al principio, puestos a que son recientes. Una vez guardados se limpia la última publicación incrementamos el índice
        // al número de publicaciones nuevas detectadas, volvemos a llamar a este método "solicitarComentarios()" para volver a solicitar comentarios
        // desde el índice actualizado, salimos del bucle y termina.

        if (widget.publicacion.numComentarios != nuevoNumComentarios) {
          // Calcular si existe una diferencia creciente (Si hay nuevos comentarios y no estamos al principio)
          if (widget.publicacion.numComentarios < nuevoNumComentarios && indiceComentarios != 0) {
            int cantidad = nuevoNumComentarios - widget.publicacion.numComentarios; // Cuantos comentarios nuevos existen
            if (!mounted) return;
            final newResponse = await Comentario.solicitarComentarios(
              context,                // CONTEXTO PARA PROBLEMAS DE CONEXIÓN
              widget.publicacion.id,  // ID DE LA PUBLICACIÓN A CONSULTAR
              0,                      // ÍNDICE DE LOS COMENTARIOS
              cantidad                // NÚMERO DE COMENTARIOS A CONSULTAR
            );

            for (int i = 0; i < newResponse.length; i++) {
              var datos = newResponse[i]; // EXTRAIGO LA INFORMACIÓN
              // CREO EL COMENTARIO
              Comentario ultimoComentario = Comentario(
                idComentario: datos["id_comentario"], 
                imagenPerfil: datos["imagen_perfil"], 
                nombre: datos["nombre"],
                usuario: datos["usuario"],
                texto: datos["texto"],
                fecha: datos["fecha_comentario"],
                numRespuestas: 0, // CAMBIAR
                likes: datos["likes"], 
                liked: datos["liked"]
              );
              setState(() {
                comentarios.insert(0, ComentarioStyle(comentario: ultimoComentario, onResponder: onResponder, onEliminar: onEliminar));
              });
            }
            indiceComentarios += cantidad; // Incrementamos el índice
            widget.publicacion.numComentarios = nuevoNumComentarios; // Actualizamos el número de comentarios
            solicitarComentarios(); // Solicitamos nuevos comentarios
            newComentarios.clear(); // Limpiamos los comentarios recibidos
            break; // Salimos del bucle
          } else {
            setState(() {
              widget.publicacion.numComentarios = nuevoNumComentarios; // Actualizamos el número de comentarios
            });
          }
        }        
      }
      // Solo recorre la colección si no está vacía, recuerdo que si se han detectado nuevos comentarios esta se vacía.
      if (newComentarios.isNotEmpty) {
        // Recorro los comentarios recibidos
        for (Comentario comentario in newComentarios){
          if (!mounted) {
            return;
          }
          setState(() {
            comentarios.add(ComentarioStyle(comentario: comentario, onResponder: onResponder, onEliminar: onEliminar));
          });
        }
        indiceComentarios += newComentarios.length;
      }
    }
    // No hay comentarios, no se solicita información a la BD o ya no hay más comentarios que cargar
    consultando = false;
  }

  @override
  void initState() {
    super.initState();
    solicitarComentarios();

    // Listener para cuando se detecta que ya no está el teclado para quitar el focus.
    KeyboardVisibilityController().onChange.listen((visible) {
      if (!visible) {
        if (!mounted){
          return;
        } else {
          reiniciarFocus();
          respondiendo = false;
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    //TEMAS
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    bool soloTexfield = (MediaQuery.of(context).viewInsets.bottom != 0);
    late var isLightMode = Provider.of<ThemeProvider>(context).isLightMode;
    Publicacion publi = widget.publicacion;

    // FocusScope Personalizado para evitar un error nativo de flutter.
    return FocusScope(
      node: ComentariosPage.focusScopeError,
      child: GestureDetector(
        onTap: () => reiniciarFocus(),
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: custom.contenedor,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            foregroundColor: custom.colorEspecial,
            actions: [
              GestureDetector(
                onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: custom.colorEspecial,
                        shape: BoxShape.circle
                      ),
                      child: CircleAvatar(
                        backgroundColor: custom.contenedor,
                        backgroundImage: (SupabaseAuthService.isLogin.value) ? CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil) : null,
                        child: (!SupabaseAuthService.isLogin.value) ? Icon(Icons.person,size: 25,color: custom.colorEspecial,) : null,
                      )
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
            ],
            title: Text("Publicación", style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Container(
                color: tema.surface,
                height: 100,
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45)
                    ),
                    color: custom.contenedor
                  ),
                  child: Column(
                    children: [
                      PublicacionStyle(publicacion: publi, isComentariosPage: true, onTapComentariosPage: () => reiniciarFocus()),
                      ...comentarios, // Listar todos los comentarios de la lista
                      if (publi.numComentarios == 0 && comentarios.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 5,
                          bottom: 30
                        ),
                        child: Text("Sin comentarios...\n¡Sé el primero en comentar!", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      if (publi.numComentarios > comentarios.length)
                      VisibilityDetector(
                        key: Key("progress-indicator"),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0 && consultando == false) {
                            solicitarComentarios();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: CircularProgressIndicator(
                            color: custom.colorEspecial,
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          // --------------------------------------------------------------------------------------
          // ESCRIBIR COMENTARIO
          bottomNavigationBar: (SupabaseAuthService.isLogin.value) ? SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Esto levanta el container
              ),
              child: IntrinsicHeight(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: custom.contenedor,
                    border: Border(
                      top: BorderSide(
                        color: custom.sombraContenedor,
                        width: 1
                      )
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // PRINCIPAL
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 5
                            ),
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: custom.colorEspecial,
                              shape: BoxShape.circle
                            ),
                            child: CircleAvatar(
                              backgroundColor: custom.contenedor,
                              backgroundImage: (SupabaseAuthService.isLogin.value) ? CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil) : null,
                              child: (!SupabaseAuthService.isLogin.value) ? Icon(Icons.person,size: 25,color: custom.colorEspecial,) : null,
                            )
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: (soloTexfield) ? 10 : 1,
                              minLines: 1,
                              maxLength: 200,
                              focusNode: focusEscribir,
                              autofocus: false,
                              buildCounter: (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) {
                                if (soloTexfield) {
                                  return Text('$currentLength / $maxLength');
                                }
                                return null; // Ocultar cuando no está enfocado
                              },
                              cursorColor: tema.primary,
                              style: TextStyle(color: tema.primary),
                              controller: controladorComentario,
                              onChanged: (value) {
                                if (value.isEmpty || value.length == 1) {
                                  setState(() {
                                    // RECARGAMOS
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: (respondiendo) ? _hintText : "Escribe tu comentario aquí...",
                                hintStyle: TextStyle(color: (isLightMode) ? Colors.grey.shade500 : custom.textoSuave),
                                fillColor: (isLightMode) ? Colors.grey.shade200 : custom.sombraContenedor,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: (isLightMode) ? Colors.grey.shade200 : custom.sombraContenedor, width: 1),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: (isLightMode) ? Colors.grey.shade200 : custom.sombraContenedor, width: 1),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: (isLightMode) ? Colors.grey.shade200 : custom.sombraContenedor, width: 1),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                            ),
                          ),
                          // BOTÓN COMENTAR A LA DERECHA (SIN TECLADO)
                          if (!soloTexfield && controladorComentario.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: IconButton(
                              onPressed: () async {
                                if (controladorComentario.text.isNotEmpty && await Seguridad.validate(context, controladorComentario.text)) {
                                  int id = Seguridad.generarID();

                                  if (!context.mounted) return;

                                  // Subir comentario
                                  Comentario.comentar(context, id, publi.id, controladorComentario.text);
                                  
                                  // Simular el comentario subido, localmente
                                  Comentario nuevoComentario = Comentario(
                                    idComentario: id,
                                    imagenPerfil: SupabaseAuthService.imagenPerfil,
                                    nombre: SupabaseAuthService.nombre,
                                    usuario: SupabaseAuthService.nombreUsuario,
                                    texto: controladorComentario.text,
                                    fecha: DateTime.now().toUtc().toString(),
                                    likes: 0,
                                    numRespuestas: 0,
                                    liked: false,
                                    esNuevo: true
                                  );
                                  // ------------------------------------------------
                                  reiniciarFocus(); // Quitar focus y reiniciar el arbol de FocusScope
                                  controladorComentario.clear(); // Limpiar TextField
                                  // ------------------------------------------------
                                  // Añadir el comentario al principio
                                  setState(() {
                                    publi.numComentarios++;
                                    comentarios.insert(0, ComentarioStyle(
                                      key: ValueKey(id),
                                      comentario: nuevoComentario,
                                      onResponder: onResponder,
                                      onEliminar: onEliminar,
                                    ));
                                  });
                                }
                              },
                              icon: Icon(Icons.pets, color: custom.contenedor),
                              padding: EdgeInsets.zero,
                              
                              style: IconButton.styleFrom(
                                backgroundColor: custom.colorEspecial,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                      // BOTON ENVIAR
                      Visibility(
                        visible: soloTexfield,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextButton(
                            onPressed: () async {
                                if (controladorComentario.text.isNotEmpty && await Seguridad.validate(context, controladorComentario.text)) {
                                int id = Seguridad.generarID();

                                if (!context.mounted) return;
                                // Subir comentario
                                Comentario.comentar(context, id, publi.id, controladorComentario.text);

                                // Simular el comentario subido, localmente
                                Comentario nuevoComentario = Comentario(
                                  idComentario: id,
                                  imagenPerfil: SupabaseAuthService.imagenPerfil,
                                  nombre: SupabaseAuthService.nombre,
                                  usuario: SupabaseAuthService.nombreUsuario,
                                  texto: controladorComentario.text,
                                  fecha: DateTime.now().toUtc().toString(),
                                  likes: 0,
                                  numRespuestas: 0,
                                  liked: false,
                                  esNuevo: true
                                );
                                // ------------------------------------------------
                                reiniciarFocus(); // Quitar focus y reiniciar el arbol de FocusScope
                                controladorComentario.clear(); // Limpiar TextField
                                // ------------------------------------------------
                                // Añadir el comentario al principio
                                setState(() {
                                  publi.numComentarios++;
                                  comentarios.insert(0, ComentarioStyle(
                                    key: ValueKey(id),
                                    comentario: nuevoComentario,
                                    onResponder: onResponder,
                                    onEliminar: onEliminar,
                                  ));
                                });
                              }
                            }, 
                            style: TextButton.styleFrom(
                              backgroundColor: (controladorComentario.text.isNotEmpty) ? custom.colorEspecial : custom.colorEspecial.withAlpha(150),
                              foregroundColor: custom.contenedor
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets),
                                SizedBox(width: 20),
                                Text("COMENTAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(width: 20),
                                Icon(Icons.pets),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ): 
          // EN CASO DE QUE LA SESIÓN NO ESTÉ INICIADA MUESTRA PARA INICIAR SESIÓN
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 20
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthController()),
                );
              }, 
              style: TextButton.styleFrom(
                foregroundColor: custom.contenedor,
                backgroundColor: custom.colorEspecial,
                padding: EdgeInsets.all(15)
              ),
              child: Text("Iniciar sesión para comentar")
            ),
          ),
          endDrawer: MenuLateral(),
        ),
      ),
    );
  }
}