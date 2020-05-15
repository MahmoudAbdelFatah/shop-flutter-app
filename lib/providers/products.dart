import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

//import '../data/dummy_data.dart';
import '../providers/product.dart';

class Products with ChangeNotifier {
  //List<Product> _items = DUMMY_PRODUCTS;
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final updateUrl =
          'https://shop-app-80d89.firebaseio.com/products/$id.json?auth=$authToken';
      http.patch(
        updateUrl,
        body: json.encode({
          'title': newProduct.title,
          'descrition': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      //TODO:
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shop-app-80d89.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedData = [];
      if (extractedData == null) {
        return;
      }
      final favoriteUrl =
          'https://shop-app-80d89.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(favoriteUrl);
      var favoriteValue;
      
      final favoriteData = json.decode(favoriteResponse.body);
      //the favorite user toggle not pressed yet
      //if (favoriteData == null) {
       // favoriteValue = false;
     // }

      extractedData.forEach((key, value) {
        loadedData.add(
          Product(
            description: value['description'] == null? '': value['description'],
            id: key,
            imageUrl: value['imageUrl'],
            price: value['price'],
            title: value['title'],

            //second question if the productId(key) still might not exist.
            isFavorite: favoriteData == null
                ? false
                : favoriteData[key] ?? favoriteValue,
          ),
        );
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-80d89.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'descrition': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
          //'isFavorite': product.isFavorite,
        }),
      );
      print(json.decode(response.body));
      Product newProduct = Product(
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct); //add at the end.
      //_items.insert(0, newProduct); // to add the new product in the index 0
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeProduct(String id) async {
    final removeUrl =
        'https://shop-app-80d89.firebaseio.com/products/$id.json?auth=$authToken';
    final removedProductIndex =
        _items.indexWhere((element) => element.id == id);
    var removedProductItem = _items[removedProductIndex];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(removeUrl);
    if (response.statusCode >= 400) {
      _items.insert(removedProductIndex, removedProductItem);
      notifyListeners();
      throw HttpException('could not delete the Product');
    }
    removedProductItem = null;
  }
}
