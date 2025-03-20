import 'package:flutter/material.dart';
import 'package:petlink/screens/Secondary/LoginPage.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late var tema = Theme.of(context).colorScheme; // EXTRAER TEMA DE LA APP
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("UserPage", style: TextStyle(color: tema.primary, fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        }, 
        backgroundColor: tema.inversePrimary,
        splashColor: tema.surface,
        child: Icon(Icons.person_add)
        ),
    );
  }
}