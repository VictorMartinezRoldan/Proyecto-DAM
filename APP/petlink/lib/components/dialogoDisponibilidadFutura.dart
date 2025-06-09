import 'package:flutter/material.dart';
import 'package:petlink/components/dialogoInformacion.dart';

class DialogoDisponibilidadFutura extends StatelessWidget {
  const DialogoDisponibilidadFutura({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogoInformacion(
      imagen: Image.asset("assets/logos/petlink_black.png"),
      titulo: "Proximamente... 🚀",
      texto: "Esta funcionalidad estará disponible en una futura actualización.\n\n(Actualizaciones futuras)",
      textoBtn: "Entendido",
      isOficialMessage: true,
    );
  }
}