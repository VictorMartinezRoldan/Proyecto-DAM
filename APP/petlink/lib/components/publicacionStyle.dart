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
    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(3, 3)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 10, right: 20),
            margin: EdgeInsets.only(bottom: 10, left: 25, top: 20, right: 25),
            child: Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade200, child: Icon(Icons.person, color: tema.secondary,),),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("NOMBRE", style: TextStyle(color: tema.primary)), 
                          Text("FECHA", style: TextStyle(color: tema.primary))
                        ],
                      ),
                      IntrinsicWidth(
                        child: Container(
                          padding: EdgeInsets.only(left: 7, right: 7, bottom: 2, top: 2),
                          decoration: BoxDecoration(
                            color: tema.inversePrimary,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.pets, size: 18),
                              SizedBox(width: 5),
                              Text("ID_USUARIO"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      
          // TEXTO DE LA PUBLICACIÓN
          Container(
            margin: EdgeInsets.only(left: 25, bottom: 20, right: 25),
            child: Text(
              "Hoy salimos a dar una vuelta y este compa no dudó en sentarse como todo un jefe en medio del pasto. No hizo nada especial, solo estuvo ahí, tranquilo, mirando todo como si el mundo fuera suyo. Y la verdad, no le falta razón.",
              style: TextStyle(color: tema.primary),
            ),
          ),
      
          // IMAGEN
          Container(
            width: 330,
            height: 250,
            margin: EdgeInsets.only(left: 25),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/imagenes_prueba/imagen_perro_pruebas.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
      
          // LIKES Y COMENTARIOS
          Container(
            margin: EdgeInsets.only(left: 25, bottom: 5, top: 2),
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
        ],
      ),
    );
  }
}
