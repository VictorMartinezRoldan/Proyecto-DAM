import 'package:flutter/material.dart';
import 'package:petlink/entidades/seguridad.dart';
import 'package:petlink/screens/PagesManager.dart';
import 'package:petlink/themes/customColors.dart';
import 'package:petlink/themes/themeProvider.dart';
import 'package:provider/provider.dart';

class NetworkErrorPage extends StatefulWidget {
  const NetworkErrorPage({super.key});

  @override
  State<NetworkErrorPage> createState() => _NetworkErrorPageState();
}

class _NetworkErrorPageState extends State<NetworkErrorPage> {

  @override
  Widget build(BuildContext context) {
    late var custom = Theme.of(context).extension<CustomColors>()!; // EXTRAER TEMA DE LA APP CUSTOM
    late var isLightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets),
            SizedBox(width: 10),
            Text("PETLINK"),
            SizedBox(width: 10),
            Icon(Icons.pets)
          ],
        ),
        foregroundColor: custom.colorEspecial,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: custom.contenedor,
            boxShadow: [
              BoxShadow(
                color: custom.sombraContenedor,
                blurRadius: 10
              )
            ],
            borderRadius: BorderRadius.circular(30)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/perros_dialogos/info_triste_${(isLightMode) ? "light" : "dark"}.png"),
              Text("Error de conexión", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
              SizedBox(height: 10),
              Text("Para poder utilizar la app\nnecesitas conexión a internet", textAlign: TextAlign.center),
              SizedBox(height:2),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context, 
                    builder: (context) => Dialog(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: custom.contenedor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: custom.colorEspecial,
                            ),
                            SizedBox(height: 20),
                            Text("Estableciendo conexión...")
                          ],
                        ),
                      ),
                    )
                  );
                  bool isConnected = await Seguridad.comprobarConexion(); // Checkea la conexión
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  // Diálogo en base al estado de la conexión
                  if (isConnected) {
                    if (!context.mounted) return;
                    showDialog(
                      context: context, 
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: custom.contenedor,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.greenAccent.shade700),
                              SizedBox(width: 10),
                              Text("Conexión establecida")
                            ],
                          ),
                        ),
                      )
                    );
                    await Future.delayed(Duration(milliseconds: 500));
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => PagesManager()),
                      (Route<dynamic> route) => false
                    );
                  } else {
                    if (!context.mounted) return;
                    showDialog(
                      context: context, 
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: custom.contenedor,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text("Conexión fallida, vuelve a intentarlo")
                            ],
                          ),
                        ),
                      )
                    );
                    await Future.delayed(Duration(milliseconds: 1200));
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: 20
                  ),
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: custom.contenedor,
                    boxShadow: [
                      BoxShadow(
                        color: custom.sombraContenedor,
                        blurRadius: 10,
                      )
                    ],
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: custom.colorEspecial),
                      SizedBox(width: 10),
                      Text("Reintentar", style: TextStyle(color: custom.colorEspecial),)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}