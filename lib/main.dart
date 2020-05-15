import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_products_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_product_screen.dart';
import './screens/orders_Screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          //The MaterialApp and all child widets listeners to this instance 'Products provider'
          update: (context, auth, previousProduct) => Products(
            auth.token,
            auth.userId,
            previousProduct == null ? [] : previousProduct.items,
          ),
          create: (context) {
            //...
          },
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previuosOrder) {
            return Orders(
              auth.token,
              auth.userId,
              previuosOrder == null ? [] : previuosOrder.orders,
            );
          },
          create: (context) {},
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            textTheme: ThemeData.light().textTheme.copyWith(
                  body1: TextStyle(
                    color: Color.fromRGBO(20, 51, 51, 1),
                  ),
                  body2: TextStyle(
                    color: Color.fromRGBO(20, 51, 51, 1),
                  ),
                  title: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  builder: (context, autoLoginsnapshot) =>
                      autoLoginsnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  future: auth.tryAutoLogin(),
                ),
          routes: {
            AuthScreen.routeName: (context) => AuthScreen(),
            ProductDetailScreen.screenName: (context) => ProductDetailScreen(),
            ProductOverviewScreen.screenName: (context) =>
                ProductOverviewScreen(),
            CartScreen.screenName: (context) => CartScreen(),
            OrdersScreen.screenName: (context) => OrdersScreen(),
            UserProductsScreen.screenName: (context) => UserProductsScreen(),
            EditProductsScreen.screenName: (context) => EditProductsScreen(),
          },
        ),
      ),
    );
  }
}
