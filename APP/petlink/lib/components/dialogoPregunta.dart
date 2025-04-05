import 'package:flutter/material.dart';
import 'package:petlink/themes/customColors.dart';

class DialogoPregunta extends StatelessWidget {
  final Image? imagen;
  final String titulo;
  final String texto;
  final String textoBtn1;
  final String textoBtn2;
  final Color? ColorBtn1;
  final Color? ColorBtn2;
  const DialogoPregunta({super.key, this.imagen, required this.titulo, required this.texto, required this.textoBtn1, required this.textoBtn2, this.ColorBtn1, this.ColorBtn2});

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
            Text(titulo, style: TextStyle(color: tema.primary, fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(height: 15),
            Text(texto, style: TextStyle(color: tema.primary, fontSize: 17)),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  }, 
                  child: Text(textoBtn1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  style: TextButton.styleFrom(
                    minimumSize: Size(110,40),
                    backgroundColor: (ColorBtn1 == null) ? Colors.redAccent.withAlpha(225) : ColorBtn1,
                    foregroundColor: custom.contenedor
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  }, 
                  child: Text(textoBtn2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  style: TextButton.styleFrom(
                    minimumSize: Size(110,40),
                    backgroundColor: (ColorBtn2 == null) ? custom.colorEspecial : ColorBtn2,
                    foregroundColor: custom.contenedor
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}