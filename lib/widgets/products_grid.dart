import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFavorite;

  ProductsGrid(this.isFavorite);
  @override
  Widget build(BuildContext context) {
    //setup a listener to my provider in the main file.
    final productsData = Provider.of<Products>(context);
    final loadedProducts =
        isFavorite ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: loadedProducts.length,
        itemBuilder: (context, i) {
          return ChangeNotifierProvider.value(
            value: loadedProducts[i],
            child: ProductItem(),
          );
        });
  }
}
