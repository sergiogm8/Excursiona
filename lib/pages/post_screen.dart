import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  XFile? image;
  XFile? photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Subir post"),
        leading: IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: Column(children: [
          const TextField(
            decoration: InputDecoration(
              hintText: "¿Qué quieres compartir?",
            ),
            maxLines: 10,
          ),
          if (image != null) ImageField(image: image),
          ElevatedButton(onPressed: selectImage, child: Text("Subir imagen")),
        ]),
      ),
    );
  }

  void selectImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? _image;
    _image = await picker.pickImage(source: ImageSource.gallery);
    _image = await picker.pickImage(source: ImageSource.camera);

    if (_image != null) {
      setState(() {
        image = _image;
      });
    }
  }
}

class ImageField extends StatelessWidget {
  final XFile? image;

  const ImageField({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(
      //     maxWidth: MediaQuery.of(context).size.width * 0.8,
      //     maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Image.file(File(image!.path)),
      ),
    );
  }
}
