import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/oders.dart';
import 'package:flutter_shop/widgets/cart_item.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';

class CartScreeen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreeenState createState() => _CartScreeenState();
}

class _CartScreeenState extends State<CartScreeen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final order = Provider.of<Orders>(context, listen: false);
    var _isLoading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text("your card"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "total",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount}",
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                      onPressed: (cart.totalAmount <= 0 || _isLoading)
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                                print("is loading true");
                              });

                              await order.addOrder(
                                  cart.items.values.toList(), cart.totalAmount);
                              setState(() {
                                _isLoading = false;
                              });
                              cart.clear();
                            },
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor, // foreground
                      ),
                      child: _isLoading
                          ? Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator())
                          : Text('ORDER NOW'))
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (ctx, index) {
                    var item = cart.items.values.toList()[index];
                    return CartItemTile(item.id, item.price, item.quantity,
                        item.title, cart.items.keys.toList()[index]);
                  }))
        ],
      ),
    );
  }
}
