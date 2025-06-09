import 'dart:io';
import 'dart:math';
import 'dart:isolate';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

@pragma('vm:entry-point')
void procesoYOLO(List<dynamic> args) async {
  // Desempaquetar argumentos recibidos desde el hilo principal (MAIN)
  SendPort sendPort = args[0];
  Interpreter modeloYolo = args[1];
  String imagePath = args[2];
  double cameraPreview_width = args[3];
  double cameraPreview_height = args[4];
  try {
    // Leer la imagen desde el archivo
    final imageBytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(imageBytes);
    if (original == null) return null;

    final originalWidth = original.width;
    final originalHeight = original.height;

    // Ajustar imagen al tamaño esperado por el modelo (640x640) manteniendo proporción
    final inputSize = 640;
    
    final scale = inputSize / max(originalWidth, originalHeight);

    final newWidth = (originalWidth * scale).round();
    final newHeight = (originalHeight * scale).round();

    final resized = img.copyResize(original, width: newWidth, height: newHeight);

    // Calcular padding (relleno) para centrar la imagen en un cuadrado
    final dx = ((inputSize - newWidth) / 2).round();
    final dy = ((inputSize - newHeight) / 2).round();

    // Crear imagen cuadrada (letterboxed) y rellenar de negro
    final square = img.Image(width: inputSize, height: inputSize);
    for (int y = 0; y < square.height; y++) {
      for (int x = 0; x < square.width; x++) {
        square.setPixel(x, y, img.ColorRgb8(0, 0, 0)); // negro RGB
      }
    }

    // Insertar imagen redimensionada centrada dentro del cuadrado
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        square.setPixel(x + dx, y + dy, pixel);
      }
    }

    // Preparar datos para el modelo YOLOv5 [1, 640, 640, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        640,
        (y) => List.generate(
          640,
          (x) {
            final pixel = square.getPixelSafe(x, y);
            return [
              (pixel.r / 255.0).toDouble(),
              (pixel.g / 255.0).toDouble(),
              (pixel.b / 255.0).toDouble()
            ];
          },
        ),
      ),
    );

    // Crear salida esperada por el modelo [1, 25200, 85]
    final output = List.generate(
      1,
      (_) => List.generate(25200, (_) => List.filled(85, 0.0)),
    );

    // Ejecutar inferencia (Preguntar a la IA)
    modeloYolo.run(input, output);
    
    const threshold = 0.6; // Porcentaje mínimo para considerarlo perro

    // Recorrer las predicciones del modelo
    for (final row in output[0]) {
      final conf = row[4];
      final classProbs = row.sublist(5);
      final maxProb = classProbs.reduce((a, b) => a > b ? a : b);
      final classIndex = classProbs.indexOf(maxProb);

      // Si se detecta un objeto con suficiente confianza y es un perro (clases 15–17)
      // PERRO = 16, pongo 15 y 17 también porque a veces las confunde y realmente es un perro.
      if (conf * maxProb > threshold && (classIndex > 14 && classIndex < 18)) {
        // Extraer coordenadas normalizadas y convertirlas a píxeles
        double x = row[0] * inputSize;
        double y = row[1] * inputSize;
        double w = row[2] * inputSize;
        double h = row[3] * inputSize;

        // Reescalar coordenadas al tamaño original de la imagen
        final centerX = ((x - dx) / scale);
        final centerY = ((y - dy) / scale);
        final width = w / scale;
        final height = h / scale;

        final left = centerX - width / 2;
        final top = centerY - height / 2;

        // Ajustar al tamaño del preview de la cámara
        final factorX = cameraPreview_width / originalWidth;
        final factorY = cameraPreview_height / originalHeight;

        x = left * factorX / 7.9; // Ajuste horizontal
        y = top * factorY / 1.55; // Ajuste vertical
        // Correcciones visuales según posición
        if (y > 400) {
          y += 60;
        } else if (y < 165) {
          y -= 30;
        }
        // Ajustar el tamaño del rectángulo
        w = w + 80;
        h = h + 50;

        // Crear mapa con coordenadas finales
        Map<String,double> coordenadas = {
          "x" : x,
          "y" : y,
          "w" : w,
          "h" : h
        };
        // ----------------
        // ✅ RESPUESTA OBTENIDA Y PREPARADA
        sendPort.send(coordenadas) ; // DEVUELVE LAS COORDENADAS
        return;
        // ----------------
      } else if (classIndex > 14 && classIndex < 18){
        // Se detectó la clase, pero sin suficiente confianza
      }
    }
    // 🚫 No se detectó perro.
    sendPort.send("PERRO_NO_ENCONTRADO") ; // DEVUELVE QUE EL PERRO NO A SIDO ENCONTRADO
  } catch (e, problema) {
    // ERROR DE EJECUCIÓN
    // 🔴⚠️ ERROR PROCESO SEPARADO DE YOLO: $e // $problema
    sendPort.send("ERROR") ; // DEVUELVE TEXTO "ERROR"
  }
}