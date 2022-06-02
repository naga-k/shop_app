import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class OrdersProvider with ChangeNotifier {
  final List<OrderItem> _orders;
  final String authToken;

  OrdersProvider(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https('shop-app-91095-default-rtdb.firebaseio.com',
        '/orders.json', {'auth': authToken});
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ));
      });
      _orders.clear();
      _orders.addAll(loadedOrders.reversed.toList());
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https('shop-app-91095-default-rtdb.firebaseio.com',
        '/orders.json', {'auth': authToken});
    final timeStamp = DateTime.now();
    http.post(url,
        body: jsonEncode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
            id: DateTime.now().toString(),
            amount: total,
            products: cartProducts,
            dateTime: timeStamp));
    notifyListeners();
  }
}
