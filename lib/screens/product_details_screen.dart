import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  // final String title;
  // final double price;

  static const routeName = 'productDetailsScreenRoute' ;
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String id = ModalRoute.of(context)?.settings.arguments as String;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),

    );
  }
}
