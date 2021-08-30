import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);
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

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? "orderBy='creatorId'&equalTo='$userId'" : "";
    final url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString";
    final List<Product> loadedProducts = [];

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;

      final favorites = await http.get(Uri.parse(
          "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken"));
      final favoriteData = json.decode(favorites.body);

      extractedData.forEach((ProdId, prodData) {
        loadedProducts.add(Product(
          id: ProdId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favoriteData ? false : favoriteData[ProdId] ?? false,
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
    final url =
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken";

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "description": product.description,
            "title": product.title,
            "price": product.price,
            "imageUrl": product.imageUrl,
            'isFavorite': product.isFavorite,
            'creatorId': userId
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
          "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";

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
        "https://flutter-shop-36738-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";
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
