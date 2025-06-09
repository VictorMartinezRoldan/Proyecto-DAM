import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class DialogoInformacion extends StatelessWidget {
  final Image? imagen;
  final String titulo;
  final String texto;
  final String textoBtn;
  final Color? ColorBtn;
  final Icon? icono;
  final bool isOficialMessage;
  const DialogoInformacion({super.key, this.imagen, required this.titulo, required this.texto, required this.textoBtn, this.ColorBtn, this.icono, this.isOficialMessage = false});

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      shadowColor: Colors.black.withAlpha(170),
      elevation: 5,
      backgroundColor: custom.contenedor,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (imagen != null) ? SizedBox(height:200, width: 200, child: imagen!) : SizedBox.shrink(),
            (icono != null && imagen == null) ? icono! : SizedBox.shrink(),
            (icono != null && imagen == null) ? SizedBox(height: 10) : SizedBox.shrink(),
            if (isOficialMessage)
            SizedBox(height: 15),
            Text(titulo, style: TextStyle(color: tema.primary, fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(height: 15),
            Text(texto, style: TextStyle(color: tema.primary, fontSize: 17), textAlign: TextAlign.center,),
            SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              }, 
              child: Text(textoBtn, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              style: TextButton.styleFrom(
                minimumSize: Size(200,50),
                backgroundColor: (ColorBtn == null) ? custom.colorEspecial : ColorBtn,
                foregroundColor: custom.contenedor
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}