import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/ordersScreenRoute";
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _fetchAndSetOrders() async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    _ordersFuture = ordersProvider.fetchAndSetOrders();
  }

  @override
  void initState() {
    _fetchAndSetOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<OrdersProvider>(
                builder: (context, orders, child) => ListView.builder(
                    itemCount: orders.orders.length,
                    itemBuilder: (ctx, i) => OrderItemWidget(
                          order: orders.orders[i],
                        )));
          } else {
            return const Center(
              child: Text('Error'),
            );
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
