import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final IconData icon;
  final Color iconColor;
  final String imagePath;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      icon: Icons.devices_rounded,
      iconColor: const Color(0xFF9B87F5),
      imagePath: json['imagePath'] as String,
    );
  }
}