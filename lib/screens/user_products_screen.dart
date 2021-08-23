import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/products.dart';
import 'package:flutter_shop/screens/edit_product_screen.dart';
import 'package:flutter_shop/widgets/app_drawer.dart';
import 'package:flutter_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/userProducts';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (_, i) => Column(
            children: [
              UserProduct(
                  productsData.items[i].id.toString(),
                  productsData.items[i].title.toString(),
                  productsData.items[i].imageUrl.toString()),
              Divider()
            ],
          ),
          itemCount: productsData.items.length,
        ),
      ),
    );
  }
}
