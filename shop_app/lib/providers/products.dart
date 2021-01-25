import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite == true).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    final url =
        'https://project-2021-2c122-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    print(url);
    try {
      final response = (await http.get(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      final urlFavorite =
          'https://project-2021-2c122-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'], 
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://project-2021-2c122-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url =
          'https://project-2021-2c122-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken"';
      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
              'isFavorite': newProduct.isFavorite,
            },
          ),
        );
        _items[index] = newProduct;
      } catch (error) {
        throw error;
      }
    } else {
      print(">>>>>>");
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://project-2021-2c122-default-rtdb.firebaseio.com/products/$id.json';
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert((existingProductIndex), existingProduct);
      notifyListeners();
      throw HttpException("Đã có lỗi xảy ra!!! Không thể xóa.");
    }
    existingProduct = null;
  }
}
