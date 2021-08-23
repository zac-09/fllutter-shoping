import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'package:provider/provider.dart';

class CartItemTile extends StatelessWidget {
  final DateTime? id;
  final double? price;
  final int? quantity;
  final String? title;
  final String? productId;
  CartItemTile(this.id, this.price, this.quantity, this.title, this.productId);
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cart.removeItem(productId as String);
      },
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('are you sure'),
                  content: Text('do you want to remove Item from the cart'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Yes')),
                  ],
                ));
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text("\$$price")),
            ),
            title: Text(title as String),
            subtitle: Text("Total: \$${price! * quantity!}"),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
