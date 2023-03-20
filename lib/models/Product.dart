import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class Product {
  String? name;
  DateTime? date;
  TimeOfDay? time;

  Product({this.name, this.date, this.time});

  factory Product.fromJson(Map<String, dynamic> jsonData) {
    return Product(name: jsonData['name'], date: jsonData['date'] == null ? null : DateTime.parse(jsonData['date']), time: jsonData['time'] == null ? null : TimeOfDay(hour: int.parse(jsonData['time'].split(":")[0]), minute: int.parse(jsonData['time'].split(":")[1].split(" ")[0])));
  }

  static Map<String, dynamic> toMap(Product product) => {
    'name': product.name,
    'date': product.date == null ? null : product.date?.toIso8601String(),
    'time': product.time == null ? null : formatTimeOfDay(product.time!)
  };

  static String encode(List<Product> products) => json.encode(
    products.map<Map<String, dynamic>>((product) => Product.toMap(product)).toList(),
  );

  static List<Product> decode(String products) => (json.decode(products) as List<dynamic>).map<Product>((item) => Product.fromJson(item)).toList();

  static String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }
}
