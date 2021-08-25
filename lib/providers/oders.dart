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

  Future<void> fetchAndSetOrders() async {
    const url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/orders.json";
    final response = await http.get(
      Uri.parse(url),
    );
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
      const url =
          "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/orders.json";
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
