import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petlink/entidades/publicacion.dart';
import 'package:petlink/services/supabase_auth.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CLASES
import 'package:petlink/components/dialogoInformacion.dart';
import 'package:petlink/components/dialogoPregunta.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/themes/themeProvider.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _textController = TextEditingController();
  final _focusNode = FocusNode(); // PARA CONTROLAR EL FOCUS DEL TEXTFIELD

  // Booleanos que identifican si tanto el texto y la imagen pasan la verificación
  // Verificación al final de la clase
  bool isTextOk = true;
  bool isImageOk = true;

  // CARGAR IMAGEN
  io.File? _imagen;
  final ImagePicker _picker = ImagePicker();

  bool _pickerActivo = false; // Decláralo en tu clase
  // Método para abrir galería o cámara y guardar la imagen
  Future<void> _seleccionarImagen(bool camara) async {
    if (_pickerActivo) return; // ya está corriendo

    _pickerActivo = true;

    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: camara ? ImageSource.camera : ImageSource.gallery,
      );

      if (imagenSeleccionada != null) {
        setState(() {
          _imagen = io.File(imagenSeleccionada.path);
          isImageOk = true;
        });
      }
    } catch (e) {
      // ❌ Error al seleccionar imagen
    } finally {
      _pickerActivo = false; // libera el bloqueo
    }
  }
  // ESTILO TEXTFIELD
  final estiloBorde = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide.none
  );


  // En el inicio muestra un dialogo para informar de que solo subir perros a la red social
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await Future.delayed(Duration(milliseconds: 500));
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => DialogoInformacion(
          imagen: Image.asset("assets/perros_dialogos/info_feliz_${(Provider.of<ThemeProvider>(context).isLightMode) ? "light" : "dark"}.png"),
          titulo: AppLocalizations.of(context)!.newPostButtonDialogReminderTitle,
          texto: AppLocalizations.of(context)!.newPostButtonDialogReminderDesc,
          textoBtn: AppLocalizations.of(context)!.newPostButtonDialogReminderButtonConfirm,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var isLightMode = Provider.of<ThemeProvider>(context).isLightMode;
    // late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),// DESENFOCAR EL TECLADO,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              // TOOLBAR
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, 
                      icon: Icon(Icons.arrow_back, color: custom.colorEspecial, size: 25)
                    )
                  ],
                ),
              ),
              // COLUMNA PRINCIPAL
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TARJETA DE LA PUBLICAION
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: custom.contenedor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: custom.sombraContenedor,
                          blurRadius: 10,
                          offset: Offset(3, 3)
                        )
                      ]
                    ),
                    constraints: BoxConstraints(
                      maxWidth: 600
                    ),
                    // COLUMNA PARA LOS ELEMENTOS DE LA PUBLICACIÓN
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGEN PERFIL, NOMBRE Y USUARIO
                        Container(
                          padding: EdgeInsets.only(bottom: 10, right: 20),
                          margin: EdgeInsets.only(
                            bottom: 10,
                            left: 25,
                            top: 20,
                            right: 25
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: CachedNetworkImageProvider(SupabaseAuthService.imagenPerfil),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(SupabaseAuthService.nombre),
                                    SizedBox(height: 1),
                                    IntrinsicWidth(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 1,
                                          bottom: 1
                                        ),
                                        decoration: BoxDecoration(
                                          color: custom.colorEspecial,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.pets, size: 18, color: custom.contenedor),
                                            SizedBox(width: 5),
                                            Text(SupabaseAuthService.nombreUsuario, style: TextStyle(color: custom.contenedor))
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // TEXTO DE LA PUBLICACION
                        Container(
                          margin: EdgeInsets.only(left: 25, bottom: 20, right: 25),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            cursorColor: custom.colorEspecial,
                            decoration: InputDecoration(
                              filled: true,
                              // SI EL TEXTO ES OK, COLOR NORMAL, SI NO ERROR == COLOR ROJO
                              fillColor: (isTextOk) ? custom.fondoSuave : Colors.redAccent.withAlpha(130),
                              border: estiloBorde,
                              enabledBorder: estiloBorde,
                              disabledBorder: estiloBorde,
                              hintText: AppLocalizations.of(context)!.newPostTitleDesc,
                              hintStyle: TextStyle(color: (isTextOk) ? custom.textoSuave : Colors.red),
                            ),
                            onTap: () {
                              // SI SE TOCA EL TEXTFIELD SE ELIMINA EL ERROR, LUEGO SE VUELVE A REVISAR
                              setState(() {
                                isTextOk = true;
                              });
                            },
                          ),
                        ),
                        // IMAGEN
                        Container(
                          width: double.infinity,
                          height: 325,
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            // CONDICIÓN:
                            // IMAGEN == NULL --> CONTENEDOR CON GALERÍA Y CÁMARA
                            // IMAGEN != NULL --> STACK CON IMAGEN + PHOTOVIEW Y BOTON PARA ELIMINAR LA FOTO
                            child: (_imagen == null) ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              color: (isImageOk) ? custom.fondoSuave : Colors.redAccent.withAlpha(130),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _seleccionarImagen(false),
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: (isImageOk) ? custom.textoSuave : Colors.red,
                                          width: 1
                                        ),
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.image, size: 50, color: (isImageOk) ? custom.textoSuave : Colors.red),
                                          SizedBox(height: 20),
                                          SizedBox(
                                            width: 200,
                                            child: Text(AppLocalizations.of(context)!.newPostImageDesc, textAlign: TextAlign.center, style: TextStyle(color: (isImageOk) ? custom.textoSuave : Colors.red, fontWeight: FontWeight.bold),)
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    color: (isImageOk) ? custom.textoSuave : Colors.red
                                  ),
                                  SizedBox(height: 10),
                                  TextButton.icon(
                                    onPressed: (){
                                      _seleccionarImagen(true);
                                    },
                                    label: Text(AppLocalizations.of(context)!.newPostCameraDesc, style: TextStyle(fontWeight: FontWeight.bold)),
                                    icon: Icon(Icons.camera_alt_rounded),
                                    style: TextButton.styleFrom(
                                      minimumSize: Size(50, 50),
                                      foregroundColor: (isImageOk) ? custom.textoSuave : Colors.red,
                                      side: BorderSide(color: (isImageOk) ? custom.textoSuave : Colors.red, width: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ) : GestureDetector(
                              onTap: () {
                                _focusNode.unfocus(); // QUITA EL ENFOQUE DEL TEXFIELD
                                // SI SE TOCA LA IMAGEN ABRE EL VISUALIZADOR DE IMÁGENES (UNO SENCILLO)
                                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Scaffold(
                                  extendBodyBehindAppBar: true, // El appBar se fusiona con el body no hace margin
                                  appBar: AppBar(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                  ),
                                  body: Hero(
                                    tag: _imagen!.path,
                                    child: PhotoView(
                                      minScale: PhotoViewComputedScale.contained,
                                      maxScale: PhotoViewComputedScale.covered * 1.5,
                                      imageProvider: FileImage(_imagen!),
                                    ),
                                  ),
                                ))
                                );
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Hero(
                                    tag: _imagen!.path,
                                    child: Image.file(_imagen!, fit: BoxFit.cover)
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _imagen = null;
                                        });
                                      },
                                      icon: Icon(Icons.close_rounded, size: 25, color: custom.colorEspecial),
                                      style: TextButton.styleFrom(
                                        backgroundColor: custom.contenedor,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            )
                          ),
                        ),
                        SizedBox(height: 25)
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // BOTON CANCELAR
                        TextButton(
                          onPressed: () async {
                            _focusNode.unfocus();
                            bool? respuesta = await showDialog<bool>(
                              context: context, 
                              builder: (context) => DialogoPregunta(
                                imagen: Image.asset("assets/perros_dialogos/preg_triste_${(isLightMode) ? "light" : "dark"}.png"),
                                titulo: AppLocalizations.of(context)!.newPostButtonDialogReminderConfirmExitTitle, 
                                texto: AppLocalizations.of(context)!.newPostButtonDialogReminderConfirmExitTitleDesc,
                                textoBtn1: AppLocalizations.of(context)!.newPostButtonDialogReminderConfirmExitYes,
                                textoBtn2: AppLocalizations.of(context)!.newPostButtonDialogReminderConfirmExitNo,
                              ),
                            );
                            if (respuesta != null && respuesta == false){
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          }, 
                          style: TextButton.styleFrom(
                            backgroundColor: custom.fondoSuave,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                          ),
                          child: Text(AppLocalizations.of(context)!.newPostButtonCancel, style: TextStyle(color: custom.textoSuave, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 55),
                        // BOTON PUBLICAR
                        TextButton(
                          onPressed: () async {
                            _focusNode.unfocus();
                            bool? respuesta = await showDialog<bool>(
                              context: context, 
                              builder: (context) => DialogoPregunta(
                                imagen: Image.asset("assets/perros_dialogos/preg_feliz_${(isLightMode) ? "light" : "dark"}.png"),
                                titulo: AppLocalizations.of(context)!.newPostButtonDialogConfirmTitle, 
                                texto: AppLocalizations.of(context)!.newPostButtonDialogConfirmTitleDesc,
                                textoBtn1: AppLocalizations.of(context)!.newPostButtonDialogConfirmButtonCancel,
                                textoBtn2: AppLocalizations.of(context)!.newPostButtonDialogConfirmButtonPublish,
                              ),
                            );
                            if (respuesta != null && respuesta == true){
                              if (await _comprobar()){
                                // LOGICA PARA SUBIR LA PUBLICACIÓN
                                if (!context.mounted) return;
                                bool resultado = await Publicacion.publicar(_textController.text, _imagen!, context);
                                if (resultado) {
                                  // DIALOGO EXITO
                                  if (!context.mounted) return;
                                  await showDialog(
                                    context: context, 
                                    builder: (context) => DialogoInformacion(
                                      imagen: Image.asset("assets/perros_dialogos/info_feliz_${(isLightMode) ? "light" : "dark"}.png"),
                                      titulo: AppLocalizations.of(context)!.newPostButtonDialogPublishedTitle, 
                                      texto: AppLocalizations.of(context)!.newPostButtonDialogPublishedTitleDesc, 
                                      textoBtn: AppLocalizations.of(context)!.newPostButtonDialogPublishedReturn,
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                } else {
                                  // DIALOGO ERROR (NO SE PUDO PUBLICAR)
                                  if (!context.mounted) return;
                                  await showDialog(
                                    context: context, 
                                    builder: (context) => DialogoInformacion(
                                      imagen: Image.asset("assets/perros_dialogos/info_triste_${(isLightMode) ? "light" : "dark"}.png"),
                                      titulo: "No se pudo publicar",
                                      texto: "Ocurrió un error al intentar publicar tu comentario. Por favor, inténtalo de nuevo más tarde.",
                                      textoBtn: "Aceptar",
                                    ),
                                  );
                                }
                              } else {
                                // DIALOGO ERROR
                                if (!context.mounted) return;
                                showDialog(
                                  context: context, 
                                  builder: (context) => DialogoInformacion(
                                    imagen: Image.asset("assets/perros_dialogos/info_triste_${(isLightMode) ? "light" : "dark"}.png"),
                                    titulo: AppLocalizations.of(context)!.newPostButtonDialogErrorTitle, 
                                    texto: AppLocalizations.of(context)!.newPostButtonDialogErrorTitleDesc, 
                                    textoBtn: AppLocalizations.of(context)!.newPostButtonDialogErrorReturn),
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: custom.colorEspecial,
                            foregroundColor: custom.contenedor,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)
                          ),
                          child: Text(AppLocalizations.of(context)!.newPostButtonPublish, style: TextStyle(fontWeight: FontWeight.bold))
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ),
    );
  }

  Future<bool> _comprobar() async{
    if(!await Seguridad.validate(context, _textController.text.trim())) {
      setState(() {
        isTextOk = false;
      });
    }
    if(_imagen == null) {
      setState(() {
        isImageOk = false;
      });
    }
    if (isTextOk && isImageOk){
      return true;
    } else {
      return false;
    }
  }
}