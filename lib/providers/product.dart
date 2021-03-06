import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/models/http_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void toggleProductStatus(String authToken, String userId) async {
    var oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://isabella-ed317-default-rtdb.firebaseio.com/userFavorites/$userId/${id}.json?auth=$authToken');
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
        throw HttpException("An error occured");
      }
    } catch (err) {
      _setFavValue(oldStatus);
      print(err);
      throw HttpException("An error occured");
    }
    oldStatus = null;
  }
}
