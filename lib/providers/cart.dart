import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart with ChangeNotifier {
  final Map<String, CartItem> _items;
  final String? authToken;
  final String? userId;
  final String serverUrl = 'shop-app-91095-default-rtdb.firebaseio.com';
  late String userPath;
  late Map<String, String> headers;

  Cart(this.authToken, this.userId, this._items) {
    userPath = 'cart/$userId.json';
    headers = {'auth': authToken ?? ''};
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchAndSetCartItems() async {
    final url = Uri.https(serverUrl, userPath, headers);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      final Map<String, CartItem> loadedItems = {};
      extractedData['items'].forEach((productData) {
        loadedItems.putIfAbsent(
          productData['id'],
          () => CartItem(
            id: productData['id'],
            title: productData['title'],
            price: productData['price'],
            quantity: productData['quantity'],
          ),
        );
      });
      _items.clear();
      _items.addAll(loadedItems);
      notifyListeners();
    } catch (error) {
      //do soemthing
    }
  }

  Future<void> _syncCartItems() async {
    final url = Uri.https(serverUrl, userPath, headers);
    http.put(url,
        body: json.encode({
          'items': _items.values.map((cartItem) {
            return {
              'id': cartItem.id,
              'title': cartItem.title,
              'quantity': cartItem.quantity,
              'price': cartItem.price
            };
          }).toList(),
          'totalAmount': totalAmount
        }));
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (cartItem) => CartItem(
              id: cartItem.id,
              title: cartItem.title,
              quantity: cartItem.quantity + 1,
              price: cartItem.price));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    _syncCartItems();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _syncCartItems();
    notifyListeners();
  }

  void removeSingeItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity,
              price: existingCartItem.price));
    } else {
      _items.remove(productId);
    }
    _syncCartItems();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _syncCartItems();
    notifyListeners();
  }
}
