import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:petlink/themes/customColors.dart';

class BarraHorasEjercicio extends StatelessWidget {
  final String horasEjercicio;
  final String imageUrl;

  const BarraHorasEjercicio({
    Key? key,
    required this.horasEjercicio,
    required this.imageUrl,
  }) : super(key: key);

  // Metodo para convertir texto en horas
  double _getProgressValue() {
    final text = horasEjercicio.toLowerCase().trim();
    switch (text) {
      case '30 minutos':
        return 0.5; // 30 min = 0.5 horas
      case '30 - 45 minutos':
        return (30 + 45) / 2 / 60; // 0.625 horas
      case '30 - 60 minutos':
        return (30 + 60) / 2 / 60; // 0.75 horas
      case '1 hora':
        return 1.0;
      case '1 - 2 horas':
        return (1 + 2) / 2; // 1.5 horas
      case '1 - 1,5 horas':
        return (1 + 1.5) / 2; // 1.25 horas
      case '1,5 - 2 horas':
        return (1.5 + 2) / 2; // 1.75 horas
      case '2 horas o más':
        return 2.5; // Valor maximo para +2 horas
      default:
        return 0.0; // Si no hay valor devolver 0
    }
  }

  @override
  Widget build(BuildContext context) {

    late var custom =Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM

    const double maxHoras = 2.0;
    const double barraWidth = 280;
    const double barraHeight = 16;
    const double perroSize = 48;

    // Calcular el valor del progreso y normalizarlo entre 0 y 1
    final double progressValue = _getProgressValue();
    final double progress = (progressValue / maxHoras).clamp(0.0, 1.0);
    // Calcular la posicion del icono dependiendo del progreso
    final double left = progress >= 1.0
    // Sumar pixeles para que el icono se vea al final del todo en 2h+
    ? barraWidth - perroSize + 6
    : (barraWidth - perroSize) * progress;

    // Contenido principal
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MingCute.barbell_line, size: 18),
            const SizedBox(width: 8),
            Text(
              'Ejercicio Diario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: barraWidth,
          height: perroSize / 2 + barraHeight,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              // Barra de fondo
              Positioned(
                left: 0,
                right: 0,
                top: perroSize / 2 - barraHeight / 2,
                child: Container(
                  width: barraWidth,
                  height: barraHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(barraHeight / 2),
                    color: custom.fondoSuave,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: i == 0 ? 8 : 4,
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 14,
                          color: (i == 2 && progressValue >= 2) ||
                                  (i < 2 && i <= progressValue)
                              ? custom.colorEspecial
                              : custom.textoSuave.withAlpha(90),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Barra de progreso animada
              Positioned(
                left: 0,
                top: perroSize / 2 - barraHeight / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width: barraWidth * progress,
                  height: barraHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(barraHeight / 2),
                    gradient: LinearGradient(
                      colors: [
                        custom.colorEspecial.withAlpha(180),
                        custom.colorEspecial,
                      ],
                    ),
                  ),
                ),
              ),
              // Avatar del perro
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                left: left,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: custom.colorEspecial.withAlpha(80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: custom.sombraContenedor.withAlpha(60),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    elevation: 0,
                    color: custom.contenedor,
                    shape: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 37,
                          height: 37,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 37,
                              height: 37,
                              color: custom.fondoSuave,
                              child: Icon(Icons.pets,
                                  color: custom.colorEspecial, size: 24),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: barraWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0h',
                style: TextStyle(
                  fontSize: 13,
                  color: progressValue > 0
                      ? custom.colorEspecial
                      : custom.textoSuave.withAlpha(120),
                  fontWeight:
                      progressValue > 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              Text(
                '1h',
                style: TextStyle(
                  fontSize: 13,
                  color: progressValue >= 1
                      ? custom.colorEspecial
                      : custom.textoSuave.withAlpha(120),
                  fontWeight:
                      progressValue >= 1 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              Text(
                '2h+',
                style: TextStyle(
                  fontSize: 13,
                  color: progressValue >= 2
                      ? custom.colorEspecial
                      : custom.textoSuave.withAlpha(120),
                  fontWeight:
                      progressValue >= 2 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          horasEjercicio,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                'Las recomendaciones son orientativas y pueden variar según la raza y el tamaño del perro.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}