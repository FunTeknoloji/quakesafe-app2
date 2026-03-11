import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title sayfası yakında eklenecek.")),
          );
        },
      ),
    );
  }
}
