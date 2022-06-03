import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = "/cartScreenRoute";
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future _cartFuture;

  Future _fetchAndSetCartItems() async {
    final cartProvider = Provider.of<Cart>(context, listen: false);
    _cartFuture = cartProvider.fetchAndSetCartItems();
  }

  @override
  void initState() {
    _fetchAndSetCartItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context, listen: false);
    final cartItems = cartProvider.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: FutureBuilder(
          future: _cartFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Column(children: [
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
                              "\$${cartProvider.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .subtitle1
                                      ?.color),
                            ),
                            backgroundColor: Theme.of(ctx).colorScheme.primary,
                          ),
                          OrderButton(cart: cartProvider, cartItems: cartItems)
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: Consumer<Cart>(
                  builder: (ctx, cart, child) => ListView.builder(
                      itemCount: cart.itemCount,
                      itemBuilder: (ctx, i) {
                        return CartItemWidget(
                          id: cart.items.values.toList()[i].id,
                          price: cart.items.values.toList()[i].price,
                          quantity: cart.items.values.toList()[i].quantity,
                          title: cart.items.values.toList()[i].title,
                          productId: cart.items.keys.toList()[i],
                        );
                      }),
                ))
              ]);
            } else {
              return const Center(
                child: Text('Error'),
              );
            }
          }),
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
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const Text("ORDER NOW"));
  }
}
