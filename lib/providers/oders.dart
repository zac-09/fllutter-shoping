import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String? id;
  final double? amount;
  final List<CartItem>? products;
  final DateTime? dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  Orders(this.authToken, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken";
    final response = await http.get(
      Uri.parse(url),
    );
    final List<OrderItem> loadedOrders = [];
    final extratedData = json.decode(response.body) as Map<String, dynamic>;
    // if (extratedData == null) {
    //   return;
    // }
    extratedData.forEach((orderId, OrderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: OrderData['amount'],
          products: (OrderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: DateTime.parse(item['id']),
                  title: item['title'],
                  quantity: int.parse(item['quantity']),
                  price: double.parse(item['price'])))
              .toList(),
          dateTime: DateTime.parse(OrderData['dateTime'])));
    });
    _orders = loadedOrders.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduts, double total) async {
    final timestamp = DateTime.now();
    try {
      final products = cartProduts
          .map((e) => {
                'id': e.id.toString(),
                'title': e.title.toString(),
                'price': e.price.toString(),
                'quantity': e.quantity.toString(),
              })
          .toList();
      print(products);
      final url =
          "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken";
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "amount": total,
            "products": products,
            "dateTime": timestamp.toIso8601String()
          }));

      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProduts,
              dateTime: timestamp));
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }
}
