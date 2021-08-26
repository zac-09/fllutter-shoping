import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    const url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products.json";
    final List<Product> loadedProducts = [];

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;

      extractedData.forEach((ProdId, prodData) {
        loadedProducts.add(Product(
          id: ProdId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    const url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products.json";

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "description": product.description,
            "title": product.title,
            "price": product.price,
            "imageUrl": product.imageUrl,
            'isFavorite': product.isFavorite
          }));

      final newProduct = Product(
          description: product.description,
          title: product.title,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      // _items.add(value);
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";

      try {
        await http.patch(Uri.parse(url),
            body: json.encode({
              "description": newProduct.description,
              "title": newProduct.title,
              "price": newProduct.price,
              "imageUrl": newProduct.imageUrl,
            }));
        _items[prodIndex] = newProduct;
      } catch (err) {
        throw err;
      }
    } else {
      print('product not found');
    }
    notifyListeners();
  }

  deleteProduct(String id) {
    final url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json";
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var exisitngProduct = items[existingProductIndex];
    _items.removeAt(existingProductIndex);

    http.delete(Uri.parse(url)).then((_) {
      exisitngProduct = null as Product;
    }).catchError((_) {
      _items.insert(existingProductIndex, exisitngProduct);
    });

    // _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
