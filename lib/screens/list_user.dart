import 'package:flutter/material.dart';

class ListUserScreen extends StatefulWidget {
  const ListUserScreen({super.key});

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('List User Screen'),
        ),
        body: SafeArea(
            child: Container(
          height: 100,
          width: 100,
          color: Colors.orange
        )));
  }
}
