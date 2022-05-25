import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_details_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  final ThemeData theme = ThemeData(
    fontFamily: 'Lato',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.purple,
          secondary: Colors.deepOrange,
        ),
      ),
      home: ProductsOverviewScreen(),
      routes: {
        ProductDetailsScreen.routeName : (ctx) => ProductDetailsScreen(),
      },
    );
  }
}