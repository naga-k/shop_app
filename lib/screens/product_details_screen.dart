import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_model_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  // final String title;
  // final double price;

  static const routeName = 'productDetailsScreenRoute' ;
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String productId = ModalRoute.of(context)?.settings.arguments as String;

    Product loadedProduct = Provider.of<ProductsProvider>(
        context,
        listen: false
    ).findById(productId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),

    );
  }
}
