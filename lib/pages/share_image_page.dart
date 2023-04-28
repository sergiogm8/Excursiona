import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShareImagePage extends StatefulWidget {
  const ShareImagePage({super.key});

  @override
  State<ShareImagePage> createState() => _ShareImagePageState();
}

class _ShareImagePageState extends State<ShareImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Image'),
      ),
      body: Container(
        child: const Center(
          child: Text('Share Image Page'),
        ),
      ),
    );
  }
}
