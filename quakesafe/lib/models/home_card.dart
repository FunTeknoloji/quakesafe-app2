import 'package:flutter/material.dart';

class HomeCard {
  final String id;
  final String title;
  final IconData icon;

  HomeCard({
    required this.id,
    required this.title,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory HomeCard.fromJson(Map<String, dynamic> json, IconData icon) {
    return HomeCard(
      id: json['id'],
      title: json['title'],
      icon: icon,
    );
  }
}
