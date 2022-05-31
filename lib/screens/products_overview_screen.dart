import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions{
  favourites,
  all
}

class ProductsOverviewScreen extends StatefulWidget {

  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavourites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue){
              setState(
                  (){
                    if( selectedValue == FilterOptions.favourites){
                      _showFavourites = true;
                    }
                    else{
                      _showFavourites = false;
                    }
                  }
              );
            },
            icon: const Icon(
              Icons.more_vert
            ),
              itemBuilder: (_) => [
                PopupMenuItem(child: Text('Only Favourites'), value: FilterOptions.favourites,),
                PopupMenuItem(child: Text('Show All'), value: FilterOptions.all,)
              ]
          )
        ],
      ),
      body: ProductsGrid(
        showFavourites: _showFavourites,
      ) ,
    );
  }
}
