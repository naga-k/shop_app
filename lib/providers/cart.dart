import 'package:flutter/material.dart';

class CartItem{
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price
  });


}

class CartProvider with ChangeNotifier{

  Map<String,CartItem> _items = {};

  Map<String, CartItem> get items{
    return {..._items};
  }
  
  void addItem(String productId, String title, double price){
    if(_items.containsKey(productId)){
      items.update(
          productId,
          (cartItem) => CartItem(
              id: cartItem.id,
              title: cartItem.title,
              quantity: cartItem.quantity + 1,
              price: cartItem.price)
      );
    }
    else
    {
        _items.putIfAbsent(
            productId,
            () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                quantity: 1,
                price: price)
        );
    }
  }
}