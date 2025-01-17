import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Screen'),
        ),
        body: SafeArea(
            child: Container(
          height: 100,
          width: 100,
          color: const Color.fromARGB(255, 45, 226, 102)
        )));
  }
}
