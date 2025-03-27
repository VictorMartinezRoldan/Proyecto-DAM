import 'package:flutter/material.dart';

class PublicacionStyle extends StatefulWidget {
  @override
  State<PublicacionStyle> createState() => _PublicacionStyleState();
}

class _PublicacionStyleState extends State<PublicacionStyle> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 10, left: 10, top: 10, right: 20),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tema.inversePrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 15, child: Icon(Icons.person)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("USUARIO"), Text("FECHA")],
                    ),
                    Row(
                      children: [
                        Icon(Icons.pets),
                        SizedBox(width: 5),
                        Text("ID_USUARIO"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // IMAGEN
        Container(
          width: 300,
          margin: EdgeInsets.only(left: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/imagenes_prueba/imagen_perro_pruebas.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),

        // LIKES Y COMENTARIOS
        Container(
          margin: EdgeInsets.only(left: 40, bottom: 5, top: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  print("LIKE");
                  setState(() {
                    liked = !liked;
                  });
                },
                icon: Icon((!liked) ? Icons.favorite_border_rounded : Icons.favorite_rounded,color: tema.primary,size: 25),
              ),
              Text("135", style: TextStyle(color: tema.primary)),
              SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  print("COMENTARIO");
                },
                icon: Icon(Icons.chat_bubble_outline_rounded,color: tema.primary,size: 25),
              ),
              Text("46", style: TextStyle(color: tema.primary)),
            ],
          ),
        ),
        // TEXTO DE LA PUBLICACIÓN
        Container(
          margin: EdgeInsets.only(left: 40, bottom: 10, right: 70),
          child: Text(
            "Hoy salimos a dar una vuelta y este compa no dudó en sentarse como todo un jefe en medio del pasto. No hizo nada especial, solo estuvo ahí, tranquilo, mirando todo como si el mundo fuera suyo. Y la verdad, no le falta razón.",
            style: TextStyle(color: tema.primary),
          ),
        ),
      ],
    );
  }
}
