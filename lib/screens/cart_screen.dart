import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cartScreenRoute";
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final cartItems = cart.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .subtitle1
                              ?.color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderButton(cart: cart, cartItems: cartItems)
                ]),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: (ctx, i) {
                  return CartItemWidget(
                    id: cartItems.values.toList()[i].id,
                    price: cartItems.values.toList()[i].price,
                    quantity: cartItems.values.toList()[i].quantity,
                    title: cartItems.values.toList()[i].title,
                    productId: cartItems.keys.toList()[i],
                  );
                }))
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
    required this.cartItems,
  }) : super(key: key);

  final Cart cart;
  final Map<String, CartItem> cartItems;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : (() async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<OrdersProvider>(context, listen: false)
                    .addOrder(widget.cartItems.values.toList(),
                        widget.cart.totalAmount)
                    .catchError((error) => null)
                    .whenComplete(() => setState(() => _isLoading = false));
                widget.cart.clearCart();
              }),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Text("ORDER NOW"));
  }
}
