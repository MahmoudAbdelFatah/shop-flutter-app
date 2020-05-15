import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';

enum FiltersOption {
  Favoirte,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  static const screenName = '/product-overview';
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isFavoriteShow = false;
  var _isInit = true;
  var _isLoaded = false;

  @override
  void initState() {
    //Provider.of<Products>(context).fatchAndSetProducts(); //DOES NOT WORK
    //First Solution
    //Future.delayed(Duration.zero).then(
    //  (value) => Provider.of<Products>(context).fatchAndSetProducts(),
    // );
    super.initState();
  }

  //Secend solution:
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoaded = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts(true).then((_) {
        setState(() {
          _isLoaded = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FiltersOption selectedValue) {
              setState(() {
                if (selectedValue == FiltersOption.Favoirte) {
                  _isFavoriteShow = true;
                } else {
                  _isFavoriteShow = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Favorite'),
                value: FiltersOption.Favoirte,
              ),
              PopupMenuItem(
                child: Text('show all'),
                value: FiltersOption.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (context, cart, _) {
              return Badge(
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.screenName);
                  },
                ),
                value: cart.itemsNumber.toString(),
              );
            },
          )
        ],
      ),
      body: _isLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_isFavoriteShow),
    );
  }
}
