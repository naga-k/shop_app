import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_model_provider.dart';
import 'package:shop_app/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: Icon(
                product.isFavourite ? Icons.favorite : Icons.favorite_border
              ),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                product.toggleFavourite();
              },
            ),
            trailing: IconButton(
              icon: const Icon(
                  Icons.shopping_cart
              ),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
              },
            ),
            title: Text(
              product.title,
            textAlign: TextAlign.center,
          ),
        ),
          child: GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
            },
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
      ),
    );
  }
}
