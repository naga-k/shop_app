import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  late bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  void setFavoriteValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavourite() async {
    final oldValue = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.https(
        'shop-app-91095-default-rtdb.firebaseio.com', '/products/${id}.json');
    try {
      final response =
          await http.patch(url, body: jsonEncode({'isFavorite': !oldValue}));
      if (response.statusCode >= 400) {
        setFavoriteValue(oldValue);
      }
    } catch (error) {
      setFavoriteValue(oldValue);
    }
  }
}
