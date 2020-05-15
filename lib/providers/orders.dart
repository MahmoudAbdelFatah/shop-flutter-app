import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../models/http_exception.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> oderItems;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.oderItems,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final authToken;
  final userId;

  Orders(
    this.authToken,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-app-80d89.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedData = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((key, value) {
        loadedData.add(OrderItem(
            id: key,
            amount: value['amount'],
            dateTime: DateTime.parse(value['dateTime']),
            oderItems: (value['oderItems'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    title: item['title'],
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ),
                )
                .toList()));
      });
      _orders = loadedData.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final DateTime dateTimeNow = DateTime.now();
    final url =
        'https://shop-app-80d89.firebaseio.com/orders/$userId.json?auth=$authToken';
    http.Response response;
    try {
      response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': dateTimeNow.toIso8601String(),
          'oderItems': cartItems
              .map(
                (cartItem) => {
                  'id': cartItem.id,
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                  'creatorId': userId,
                },
              )
              .toList(),
        }),
      );
    } catch (error) {
      print(json.decode(response.body)['name']);
    }

    _orders.insert(
      0,
      OrderItem(
        amount: total,
        id: json.decode(response.body)['name'],
        oderItems: cartItems,
        dateTime: dateTimeNow,
      ),
    );
    notifyListeners();
  }

  Future<void> removeOrderItem(String id) async {
    final removeUrl =
        'https://shop-app-80d89.firebaseio.com/orders/$id.json?auth=$authToken';
    final removedOrderIndex = _orders.indexWhere((element) => element.id == id);
    var removedOrderItem = _orders[removedOrderIndex];
    _orders.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(removeUrl);
    if (response.statusCode >= 400) {
      _orders.insert(removedOrderIndex, removedOrderItem);
      notifyListeners();
      throw HttpException('could not delete the Order!');
    }
    removedOrderItem = null;
    notifyListeners();
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}
