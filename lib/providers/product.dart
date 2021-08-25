import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? price;
  bool isFavorite;
  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.imageUrl,
      @required this.price,
      this.isFavorite = false})
      : assert(id != null);
  Future<void> toggleFavorite() async {
    var url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'isFavorite': isFavorite,
          }));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (err) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
