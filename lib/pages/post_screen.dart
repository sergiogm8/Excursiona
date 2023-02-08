import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Subir post"),
        leading: IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Column(children: [
          const TextField(
            decoration: InputDecoration(
              hintText: "¿Qué quieres compartir?",
            ),
          ),
          ElevatedButton(onPressed: selectImage, child: Text("Subir imagen")),
        ]),
      ),
    );
  }

  void selectImage() {}
}
