import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/PetWikiInformationPage.dart';
import 'package:petlink/themes/customColors.dart';

class DialogoRaza extends StatefulWidget {
  final Map<String, dynamic>? razaData;
  const DialogoRaza({super.key, required this.razaData});

  @override
  State<DialogoRaza> createState() => _DialogoRazaState();
}

class _DialogoRazaState extends State<DialogoRaza> {

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
      return Stack(
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            shadowColor: Colors.black.withAlpha(170),
            elevation: 5,
            backgroundColor: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.razaData!["raza"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: custom.colorEspecial,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Aquí empieza el contenedor con scroll
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5, // hasta el 50% de alto
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: custom.contenedor,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpandableText(
                            widget.razaData!["descripcion"],
                            expandText: '\nVer más ↓',
                            collapseText: '\nVer menos ↑',
                            maxLines: 6,
                            linkColor: custom.colorEspecial,
                            animation: true,
                            animationDuration: Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: tema.onSurface.withAlpha(204),
                            ),
                            linkStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: custom.colorEspecial,
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(imageUrl: widget.razaData!["bio_imagen"],),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10, // Ajusta según lo que necesites
            right: 0,
            left: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PetWikiInformationPage(razaData: widget.razaData))),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 35),
                  child: Dialog(
                    backgroundColor: Colors.black,
                    child: Container(
                      padding: EdgeInsets.all(13),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(1),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: custom.contenedor,
                                borderRadius: BorderRadius.circular(15)
                              ),
                              child: Text("Ir a la wiki", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(width: 30),
                          Icon(Icons.arrow_forward_ios_rounded, color: custom.colorEspecial),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
  }
}