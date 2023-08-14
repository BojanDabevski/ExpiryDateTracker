import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RecipeModel {
  final String image;
  final String url;
  final String source;
  final String label;

  RecipeModel({  required this.image,  required this.url,  required this.label, required this.source});

  factory RecipeModel.fromMap(Map<String, dynamic> parsedJson) {
    return RecipeModel(
        image: parsedJson["image"],
        url: parsedJson["url"],
        source: parsedJson["source"],
        label: parsedJson["label"]);
  }
}