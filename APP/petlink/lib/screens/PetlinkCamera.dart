import 'package:flutter/material.dart';
import 'package:camera/camera.dart';                          // Para usar la cámara nativa de flutter
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';  // Para pedir permisos de cámara manualmente
import 'package:image_picker/image_picker.dart';              // Para abrir la galería
import 'package:audioplayers/audioplayers.dart';              // Para reproducir sonidos
import 'package:lottie/lottie.dart';                          // Para animaciones
import 'dart:io';                                             // Trabajar con archivos
import 'package:image/image.dart' as img;                     // Para procesamiento de imágenes
import 'package:flutter/foundation.dart';                     // Para usar compute y procesos pesados en segundo plano
import 'package:petlink/components/dialogoRaza.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/procesos_pesados/proceso_modelo_razas.dart';
import 'package:petlink/screens/Secondary/NetworkErrorPage.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:isolate';
import 'package:tflite_flutter/tflite_flutter.dart';

// CLASES
import 'package:petlink/main.dart';
import 'package:petlink/procesos_pesados/proceso_modelo_yolo.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/components/dialogoPregunta.dart';
import 'package:petlink/components/EsquinasCamara.dart';
import 'package:petlink/components/dialogoInformacion.dart';

// Método separado

// ESTE MÉTODO SE EJECUTA EN SEGUNDO PLANO PORQ ES PESADO
void flipImage(String path) {
  final file = File(path);
  final bytes = file.readAsBytesSync();
  final img.Image original = img.decodeImage(bytes)!;
  final img.Image flipped = img.flipHorizontal(original);
  final newBytes = img.encodeJpg(flipped);
  file.writeAsBytesSync(newBytes);
}

// -------------------------------------------------------

// INICIO DE LA CLASE
class PetlinkCamera extends StatefulWidget {
  const PetlinkCamera({super.key});

  @override
  State<PetlinkCamera> createState() => _PetlinkCameraState();
}

// -------------------------------------------------------

class _PetlinkCameraState extends State<PetlinkCamera> {

  // ATRIBUTOS
  late CameraController _cameraController; // Controlador de la cámara
  bool _isCameraInitialized = false;
  int _selectedCameraIndex  = 0; // Cámara trasera (0) o delantera (1)
  XFile? imagen;
  bool _isPickingImage = false; // Galería abierta o ya en uso
  bool _searchAnimationVisible = false; // Si muestra la animación de búsqueda
  bool _tomandoFoto = false;

  // Para relacionar el modo de la cámara con un icono.
  final flashIcons = {
    FlashMode.off : Icons.flash_off,
    FlashMode.always : Icons.flash_on,
    FlashMode.torch : Icons.sunny
  };

  // COORDENADAS Y DIMENSIONES DETECTOR PERRO
  double caja_eje_x = 30;
  double caja_eje_y = 130;
  double caja_anchura = 330;
  double caja_altura = 400;

  // BUSCANDO RAZA
  bool buscandoRaza = false;

  late Interpreter modeloYolo;
  late Interpreter modeloRazas;

  // MÉTODOS

  Future<void> _cargarModelos() async {
    // CARGA EL MODELO
    modeloYolo = await Interpreter.fromAsset('assets/IA/yolo/yolov5.tflite');
    modeloRazas = await Interpreter.fromAsset('assets/IA/razas/detector.tflite');
  }


  // MÉTODO PARA INICIALIZAR LA CAMARA
  // - PIDE PERMISOS Y LOS CONTROLA
  Future<void> _initializeCamera() async {
    try {
      final cameras = await MyApp.cameras; // Recoge la información sobre las cámaras disponibles.
      _cameraController = CameraController(cameras[_selectedCameraIndex], ResolutionPreset.ultraHigh, enableAudio: false); // CONFIGURACIÓN

      // Inicializar cámara, enfoque automático y flash apagado por defecto.
      await _cameraController.initialize();
      await _cameraController.setFocusMode(FocusMode.auto);
      await _cameraController.setFlashMode(FlashMode.off);
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true; // A partir de aquí funciona en CameraPreview
        });
      }
    } catch (e) {
      print("Error al inicializar la cámara: $e");
      // Si da error muestra el diálogo diciendo que necesita permisos para continuar
      if (!mounted) return;
      bool respuesta = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DialogoPregunta(
          titulo: "Ups, no podemos continuar", 
          texto: "Para poder usar esta función necesitamos permisos para acceder a la Cámara.", 
          textoBtn1: "Volver", 
          textoBtn2: "Dar permisos",
          imagen: Image.asset("assets/perros_dialogos/preg_triste_light.png"),
          )
        )
      );
      if (respuesta != null) {
        if (respuesta == false){
          if (!mounted) return;
          Navigator.pop(context); // Vuelve para la pantalla principal
        } else {
          // Vuelve a pedir permisos si el usuario decide dar permisos.
          var statusCamera = await Permission.camera.request();
          // Si no se consigue dar permisos o el sistema bloquea volver a pedir permisos redirige a ajustes de la aplicación
          // donde el cliente puede dar permisos
          if (statusCamera.isDenied || statusCamera.isPermanentlyDenied) {
            if (!mounted) return;
            Navigator.pop(context);
            openAppSettings();
          } else {
            _initializeCamera(); // Volver a inicializar la cámara con los permisos necesarios.
          }
        }
      }
    }
  }

  // MÉTODO PARA CAMBIAR EL FLASH
  Future<void> cambiarFlash() async {
    if (!_cameraController.value.isInitialized) return;
    final currentFlash = _cameraController.value.flashMode; // MODO DE FLASH ACTUAL
    FlashMode newFlash;

    // CAMBIO ENTRE MODOS
    switch (currentFlash) {
      case FlashMode.off:
        newFlash = FlashMode.always;
        break;
      case FlashMode.always:
        // SI LA CÁMARA ES LA DELANTERA SOLO PERMITE MODO = (OFF/ALWAYS)
        if (_selectedCameraIndex == 1) {
          newFlash = FlashMode.off;
        } else {
          newFlash = FlashMode.torch;
        }
        break;
      case FlashMode.torch:
        newFlash = FlashMode.off;
        break;
      default:
        newFlash = FlashMode.off;
    }

    await _cameraController.setFlashMode(newFlash);
    setState(() {}); // Para refrescar el icono en pantalla
  }

  // Método que crea un Isolate (Hilo separado, más aislado y seguro, no comparte memoria y se comunican solo por mensajes)
  // Y este lo que hace es hacer una predicción con 'YOLOv5' en busca de un perro en la imagen y devuelve unas coordenadas
  // traducidas de la posición del perro.
  Future<void> buscarPerro(String imagePath) async {
    final puertoReceptorYolo = ReceivePort(); // Puerto receptor YOLO
    final puertoReceptorRazas = ReceivePort(); // Puerto receptor RAZAS

    // Crea isolate y ejecuta la función
    Isolate.spawn(procesoYOLO, [
      puertoReceptorYolo.sendPort, // Puerto de envío
      modeloYolo, // Modelo de YOLO
      imagePath, // Ruta de la imagen
      _cameraController.value.previewSize!.width, // Ancho de vista previa de la cámara
      _cameraController.value.previewSize!.height // Alto de vista previa de la cámara
    ]);

    // RAZA
    setState(() {
      buscandoRaza = true;
    });
    
    Isolate.spawn(procesoRazas, [
      puertoReceptorRazas.sendPort, // Puerto de envío
      modeloRazas, // Modelo de RAZAS
      imagePath, // Ruta de la imagen
    ]);

    // Se pone en segundo plano a la espera de resultado por parte del método
    puertoReceptorYolo.listen((resultado) async {
      setState(() {
        _searchAnimationVisible = false;
        buscandoRaza = false;
      });
      try {
        setState(() {
          // Intenta establecer los nuevos valores
          caja_eje_x = resultado['x']!;
          caja_eje_y = resultado['y']!;
          caja_anchura = resultado['w']!;
          caja_altura = resultado['h']!;
        });
      } catch (e) {
        // NO SE A ENCONTRADO UN PERRO
      } finally {
        await Future.delayed(Duration(seconds: 1));
        // DETECTOR DE RAZAS
        puertoReceptorRazas.listen((resultado) async {
          int clase = resultado['classIndex'];
          if (resultado is Map) {
            final contenido = await rootBundle.loadString('assets/IA/razas/clases.txt');
            final lineas = contenido.split('\n').map((e) => e.trim()).toList();
            if (clase < 0 || clase >= lineas.length) {
              throw RangeError("❌ Índice fuera de rango. El archivo tiene ${lineas.length} líneas.");
            }
            
            print("Raza detectada: clase ${lineas[clase].trim()} con ${resultado['confidence'] * 100}%");
          
            try {
              final respuesta = await Supabase.instance.client
                .from('perros')
                .select('*')
                .eq('raza', '${lineas[clase].trim()}'); 
              if (respuesta.isEmpty) {
                throw Exception("Raza no encontrada");
              } 
              if (!mounted) return;
              await showDialog(context: context, builder: (context) => DialogoRaza(razaData: respuesta.first));
            } catch (e) {
              if (!mounted) return;
              await showDialog(
                context: context, 
                builder: (context) => DialogoInformacion(
                  imagen: Image.asset("assets/perros_dialogos/info_triste_${(Provider.of<ThemeProvider>(context).isLightMode) ? "light" : "dark"}.png"),
                  titulo: "Raza no detectada",
                  texto: "Ocurrió un error al intentar detectar la raza del perro. Por favor, inténtalo de nuevo más tarde.",
                  textoBtn: "Aceptar",
                ),
              );
              // ERROR
              bool isConnected = await Seguridad.comprobarConexion();
              if (!isConnected) {
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NetworkErrorPage())
                );
              }
            } finally {
              setState(() {
                imagen = null;
                // RESTABLECEMOS LA CAJA
                caja_eje_x = 30;
                caja_eje_y = 130;
                caja_anchura = 330;
                caja_altura = 400;
              });
            }
          }
        });
      }
    });
  }

  // -------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _cargarModelos();
    // Mensaje de aviso de que es una versión Beta
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await Future.delayed(Duration(milliseconds: 500));
      if (!mounted) return;
      var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
      await showDialog(
        context: context,
        builder: (context) => DialogoInformacion(
          titulo: "AVISO: Versión Beta",
          texto: "La función de reconocimiento de raza mediante inteligencia artificial se encuentra en fase de desarrollo y mejora. Debido a esto, los resultados pueden no ser precisos.\n\n"
                "MODO DE USO:\n"
                "Analiza solo un perro a la vez, asegúrate de que el perro esté centrado en el recuadro y utiliza una imagen clara, bien iluminada, ya sea tomada con la cámara o seleccionada desde tu galería.\n\n"
                "Agradecemos tu comprensión mientras seguimos mejorando esta funcionalidad.",
          textoBtn: "Aceptar y continuar",
          icono: Icon(Icons.info_outline, color: custom.colorEspecial, size: 60),
        ),
      );
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------

  // CONSTRUCTOR DEL WIDGET
  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM

    double deviceRatio = 0.00;
    double previewRatio = 0.00;

    if (_isCameraInitialized) {
      // Calcula la relación de aspecto de la pantalla del dispositivo (deviceRatio)
      // y la del preview de la cámara (previewRatio) para ajustar el tamaño del CameraPreview
      // y evitar que se vea estirado o recortado.
      final size = MediaQuery.of(context).size;
      deviceRatio = size.width / size.height;
      final previewSize = _cameraController.value.previewSize!;
      previewRatio = previewSize.height / previewSize.width;
    }

    // DISEÑO DE LA INTERFAZ
    return PopScope( // PROHIBIR VOLVER HASTA QUE SE CONSTRUYA CORRECTAMENTE LA CÁMARA O VUELVA DE FORMA SEGURA
      canPop: _isCameraInitialized,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: (!_isCameraInitialized),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets),
              SizedBox(width: 10),
              Text("PETLINK", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Icon(Icons.pets),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white
        ),
        body: !_isCameraInitialized
            ? Center(child: CircularProgressIndicator(color: custom.colorEspecial)) : 
            Stack(
              children: [
                Transform.scale(
                  scale: previewRatio / deviceRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: previewRatio,
                      // Gira la imagen en el eje X para que se vea más natural
                      child: Transform.flip(
                        flipX: (_selectedCameraIndex == 1) ? true : false,
                        child: (imagen == null) ? 
                        CameraPreview(_cameraController) : Image.file(File(imagen!.path))
                      ),
                    ),
                  ),
                ),
                EsquinasCamara(
                  x: caja_eje_x, 
                  y: caja_eje_y, 
                  width: caja_anchura, 
                  height: caja_altura
                ),
                // BOTÓN DE FLASH
                if (imagen == null)
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    onPressed: () {
                      cambiarFlash();
                    }, 
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(flashIcons[_cameraController.value.flashMode], color: Colors.white),
                    )
                  ),
                ),
                // TEXTO DE IA
                if (imagen == null)
                Positioned(
                  right: 20,
                  top: 33,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text("AI Camera", style: TextStyle(color: Colors.black),)
                  )
                ),
                // ANIMACIÓN DE BUSCAR (LA LUPA)
                AnimatedOpacity(
                  opacity: _searchAnimationVisible ? 1 : 0,
                  duration: Duration(seconds: 1),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 120),
                      child: Lottie.asset(
                        'assets/animaciones/buscando.json',
                        width: 150,
                        height: 150,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: Duration(seconds: 1),
                      opacity: buscandoRaza ? 1 : 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: Text("Buscando raza...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ),
                )
              ],
            ),
        // CONTROLES INFERIORES DE LA CÁMARA (GIRAR CÁMARA / TOMAR FOTO / IMAGEN GALERÍA)
        bottomNavigationBar: (!_isCameraInitialized || imagen != null) ? SizedBox.shrink() : Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30
          ),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(40)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                // CAMBIAR CAMARA (TRASERA / DELANTERA)
                child: IconButton(
                  onPressed: () async {
                    if (_selectedCameraIndex == 0) {
                      _selectedCameraIndex = 1;
                    } else {
                      _selectedCameraIndex = 0;
                    }
                    await _cameraController.setFlashMode(FlashMode.off);
                    setState(() {
                      _isCameraInitialized = false;
                      _initializeCamera();
                    });
                  }, 
                  icon: Icon(Icons.cameraswitch, color: Colors.white, size: 40))
              ),
              // HACER FOTO
              GestureDetector(
                onTap: () async {
                  if (!_tomandoFoto) {
                    _tomandoFoto = true;
                    AudioPlayer player = AudioPlayer();
                    if (_selectedCameraIndex == 1 && _cameraController.value.flashMode == FlashMode.always){
                      showDialog(
                        context: context,
                        builder: (context) => Container(color: Colors.white),
                      );
                    }
                    try {
                      imagen = await _cameraController.takePicture();
                    } catch (e){
                      print("ERROR DE CÁMARA");
                    }
                    if (imagen != null) {
                      setState(() {
                        player.play(AssetSource("audios/HacerFoto.mp3"));
                      });
                      if (_selectedCameraIndex == 1 && _cameraController.value.flashMode == FlashMode.always){
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                      Future.delayed(
                        Duration(milliseconds: 600),
                        () => setState(() {
                          _searchAnimationVisible = true;
                        }),
                      );
                      if (_selectedCameraIndex == 1) await compute(flipImage, imagen!.path);
                      Future.delayed(
                        Duration(seconds: 1),
                        () => buscarPerro(imagen!.path),
                      );
                    }
                    _tomandoFoto = false;
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4
                    )
                  ),
                ),
              ),
              // BOTÓN GALERÍA
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(15)
                ),
                child: IconButton(
                  onPressed: () async {
                    if (_isPickingImage) return; // Evita llamadas múltiples
                    _isPickingImage = true;
                    try {
                      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (img != null){
                        setState(() {
                          imagen = img;
                        });
                        Future.delayed(
                          Duration(milliseconds: 600),
                          () => setState(() {
                            _searchAnimationVisible = true;
                          }),
                        );
                        buscarPerro(imagen!.path);
                      } else {
                      }
                    } finally {
                      _isPickingImage = false;
                    }
                  }, 
                  icon: Icon(Icons.photo_library_rounded, color: Colors.white, size: 32)
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}