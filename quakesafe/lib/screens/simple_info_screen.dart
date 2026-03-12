import 'package:flutter/material.dart';

class SimpleInfoScreen extends StatelessWidget {
  final String title;
  const SimpleInfoScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text("$title yakında burada olacak.", style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
