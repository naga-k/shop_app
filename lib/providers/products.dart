import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/product_model.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  late List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get itemsFavourite {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'shop-app-91095-default-rtdb.firebaseio.com', '/products.json');
    try {
      final reponse = await http.get(url);
      final extractedData = json.decode(reponse.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodDetails) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodDetails['title'],
          description: prodDetails['description'],
          price: prodDetails['price'],
          imageUrl: prodDetails['imageUrl'],
          isFavourite: prodDetails['isFavorite'],
        ));
        _items = loadedProducts;
      });
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<http.Response> addNewProductToServer(Product product) async {
    final url = Uri.https(
        'shop-app-91095-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavourite,
          }));
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<http.Response> updateProductOnServer(Product product) async {
    final url = Uri.https('shop-app-91095-default-rtdb.firebaseio.com',
        '/products/${product.id}.json');
    try {
      final response = await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavourite,
          }));
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addUpdateProduct(Product product) async {
    try {
      http.Response response;
      String newId;
      if (product.id.isEmpty) {
        response = await addNewProductToServer(product);
        newId = jsonDecode(response.body)['name'];
      } else {
        response = await updateProductOnServer(product);
        newId = product.id;
      }

      Product newProduct = Product(
        id: newId,
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      int prodIndex = _items
          .indexWhere((exisitngProduct) => exisitngProduct.id == product.id);
      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
      } else {
        _items.add(newProduct);
      }
      notifyListeners();
    } catch (error) {
      {
        rethrow;
      }
    }
  }

  void deleteProduct(String prodId) {
    final url = Uri.https('shop-app-91095-default-rtdb.firebaseio.com',
        '/products/${prodId}.json');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == prodId);
    final existingProduct = _items[existingProductIndex];
    _items.removeWhere((prod) => prod.id == prodId);
    http.delete(url).then((value) {
      if (value.statusCode >= 400) {
        // throw
      }
    }).catchError((onError) {
      _items.insert(existingProductIndex, existingProduct);
    });

    notifyListeners();
  }
}
