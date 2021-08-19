import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/oders.dart' show Orders;
import 'package:flutter_shop/widgets/app_drawer.dart';
import 'package:flutter_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your orders"),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
          itemCount: orderData.orders.length,
          itemBuilder: (ctx, index) => OrderItem(orderData.orders[index])),
    );
  }
}
